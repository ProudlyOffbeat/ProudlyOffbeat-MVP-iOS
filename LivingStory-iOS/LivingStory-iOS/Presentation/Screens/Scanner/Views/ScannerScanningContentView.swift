//
//  ScannerScanningContentView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class ScannerScanningContentView: UIView {

    // MARK: - Properties

    weak var cameraDelegate: CameraPreviewDelegate? {
        didSet { cameraPreviewView.delegate = cameraDelegate }
    }

    // MARK: - UI Components

    private let cameraPreviewView = CameraPreviewView()

    private let flashlightButton = GlassCircleButton(
        icon: .flashlightOff,
        activeIcon: .flashlightOn,
        activeColor: UIColor(hex: 0xFFCB24),   // 활성화 시 노랑
        size: 50
    )

    private let guideView = ScannerGuideView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        setupHierarchy()
        setupLayout()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func checkPermissionAndSetup() {
        cameraPreviewView.checkPermissionAndSetup()
    }

    func startScanning() {
        cameraPreviewView.startScanning()
    }

    func stopScanning() {
        cameraPreviewView.stopScanning()
    }

    func toggleFlashlight() -> Bool {
        let isOn = cameraPreviewView.toggleFlashlight()
        flashlightButton.isActive = isOn
        return isOn
    }
}

// MARK: - Setup

private extension ScannerScanningContentView {

    func setupHierarchy() {
        addSubview(cameraPreviewView)
        addSubview(flashlightButton)
        addSubview(guideView)
    }

    func setupLayout() {
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
        flashlightButton.translatesAutoresizingMaskIntoConstraints = false
        guideView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cameraPreviewView.topAnchor.constraint(equalTo: topAnchor),
            cameraPreviewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cameraPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cameraPreviewView.heightAnchor.constraint(equalTo: cameraPreviewView.widthAnchor, multiplier: 0.75),

            flashlightButton.bottomAnchor.constraint(equalTo: cameraPreviewView.bottomAnchor, constant: -16),
            flashlightButton.centerXAnchor.constraint(equalTo: cameraPreviewView.centerXAnchor),

            guideView.topAnchor.constraint(equalTo: cameraPreviewView.bottomAnchor, constant: 24),
            guideView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            guideView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    func setupActions() {
        flashlightButton.addTarget(self, action: #selector(flashlightTapped), for: .touchUpInside)
    }

    @objc func flashlightTapped() {
        _ = toggleFlashlight()
    }
}
