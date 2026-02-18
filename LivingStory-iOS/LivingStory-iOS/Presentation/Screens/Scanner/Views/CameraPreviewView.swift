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
                        self?.delegate?.cameraPreviewPermissionDenied(self!)
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
              isbn != lastDetectedISBN else { return }

        lastDetectedISBN = isbn
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.cameraPreview(self, didDetectBarcode: isbn)
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
