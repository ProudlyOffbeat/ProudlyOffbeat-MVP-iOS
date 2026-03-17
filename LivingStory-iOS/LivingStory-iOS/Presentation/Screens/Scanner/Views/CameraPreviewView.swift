//
//  CameraPreviewView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit
import AVFoundation

// MARK: - Delegate Protocol

protocol CameraPreviewDelegate: AnyObject {
    func cameraPreview(_ view: CameraPreviewView, didDetectBarcode isbn: String)
    func cameraPreviewPermissionDenied(_ view: CameraPreviewView)
}

/// 바코드 감지 시 바운딩 박스 축소 애니메이션 완료 후 delegate에 isbn 전달
/// (홈앱 QR 감지 애니메이션 차용)

// MARK: - CameraPreviewView

final class CameraPreviewView: UIView {

    // MARK: - Properties

    weak var delegate: CameraPreviewDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    private var isSessionRunning = false
    private var lastDetectedISBN: String?

    private let focusIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        view.layer.borderColor = UIColor.systemYellow.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private let boundingBoxView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemYellow.cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        view.isHidden = true
        return view
    }()

    private var pendingISBN: String?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupTapGesture()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    // MARK: - Public Methods

    func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                        self?.startScanning()
                    } else {
                        guard let self else { return }
                        self.delegate?.cameraPreviewPermissionDenied(self)
                    }
                }
            }
        case .denied, .restricted:
            delegate?.cameraPreviewPermissionDenied(self)
        @unknown default:
            break
        }
    }

    func startScanning() {
        lastDetectedISBN = nil
        pendingISBN = nil
        boundingBoxView.isHidden = true
        boundingBoxView.alpha = 0
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.startRunning()
            self?.isSessionRunning = true
        }
    }

    func stopScanning() {
        guard let session = captureSession, session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.stopRunning()
            self?.isSessionRunning = false
        }
    }

    func toggleFlashlight() -> Bool {
        guard let device = captureDevice, device.hasTorch else { return false }

        do {
            try device.lockForConfiguration()
            let newMode: AVCaptureDevice.TorchMode = device.torchMode == .on ? .off : .on
            device.torchMode = newMode
            device.unlockForConfiguration()
            return newMode == .on
        } catch {
            return false
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraPreviewView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let isbn = readableObject.stringValue,
              isbn != lastDetectedISBN,
              let previewLayer,
              let transformedObject = previewLayer.transformedMetadataObject(for: readableObject)
        else { return }

        lastDetectedISBN = isbn
        pendingISBN = isbn

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.showBoundingBoxAnimation(for: transformedObject.bounds)
        }
    }
}

// MARK: - Private Methods

private extension CameraPreviewView {

    func setupStyle() {
        backgroundColor = .black
        layer.cornerRadius = 20
        clipsToBounds = true
        addSubview(focusIndicator)
        addSubview(boundingBoxView)
    }

    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        focusAt(point: point)
        showFocusIndicator(at: point)
    }

    func focusAt(point: CGPoint) {
        guard let device = captureDevice,
              let previewLayer else { return }

        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

        do {
            try device.lockForConfiguration()

            // 탭한 위치에 초점
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }

            device.unlockForConfiguration()
        } catch {}

        // 1.5초 후 연속 오토포커스로 복귀
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let device = self?.captureDevice else { return }
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()
            } catch {}
        }
    }

    func showBoundingBoxAnimation(for barcodeBounds: CGRect) {
        // 바코드 bounds에 여유 패딩 추가
        let padding: CGFloat = 16
        let paddedBounds = barcodeBounds.insetBy(dx: -padding, dy: -padding)

        // 초기 상태: 카메라 프리뷰 전체 크기
        boundingBoxView.frame = bounds
        boundingBoxView.layer.cornerRadius = 20
        boundingBoxView.isHidden = false
        boundingBoxView.alpha = 1

        // 햅틱 피드백
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // 바코드 크기로 축소 애니메이션 (0.6초 + 스프링)
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3
        ) {
            self.boundingBoxView.frame = paddedBounds
            self.boundingBoxView.layer.cornerRadius = 6
        } completion: { [weak self] _ in
            guard let self, let isbn = self.pendingISBN else { return }
            // 바운딩 박스 잠깐 유지 후 delegate 호출
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.delegate?.cameraPreview(self, didDetectBarcode: isbn)
                self.pendingISBN = nil
            }
        }
    }

    /// 외부에서 바운딩 박스를 숨길 때 호출
    func hideBoundingBox() {
        UIView.animate(withDuration: 0.2) {
            self.boundingBoxView.alpha = 0
        } completion: { [weak self] _ in
            self?.boundingBoxView.isHidden = true
        }
    }

    func showFocusIndicator(at point: CGPoint) {
        focusIndicator.center = point
        focusIndicator.isHidden = false
        focusIndicator.alpha = 1
        focusIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

        UIView.animate(withDuration: 0.2) {
            self.focusIndicator.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: 1.0) { [weak self] in
            self?.focusIndicator.alpha = 0
        } completion: { [weak self] _ in
            self?.focusIndicator.isHidden = true
        }
    }

    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureDevice = device

        do {
            try device.lockForConfiguration()

            // 오토포커스 (근거리 ~ 원거리 모두 대응)
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .none
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            // 1.5x 줌 (15~25cm 거리에서 바코드 인식 최적)
            let zoomFactor: CGFloat = 1.5
            device.videoZoomFactor = min(zoomFactor, device.activeFormat.videoMaxZoomFactor)

            device.unlockForConfiguration()
        } catch {}

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8]
        }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.insertSublayer(layer, at: 0)

        captureSession = session
        previewLayer = layer
    }
}
