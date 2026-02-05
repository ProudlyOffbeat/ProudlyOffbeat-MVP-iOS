//
//  ScannerViewController.swift
//  LivingStory-iOS
//
//  🧑‍💻 담당: 데미안 (UIKit)
//
//  📚 AVFoundation 바코드 스캔 (나중에 구현)
//  - AVCaptureSession 설정
//  - AVCaptureMetadataOutput으로 ISBN 인식
//

import UIKit

final class ScannerViewController: UIViewController {

    weak var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .black
        title = "스캐너"
    }

    private func setupLayout() {
        // TODO: 카메라 프리뷰 레이아웃
    }

    private func setupActions() {
        // TODO: 스캔 완료 시 coordinator?.showBookProfile() 호출
    }
}

// MARK: - Preview

#Preview {
    ScannerViewController()
}
