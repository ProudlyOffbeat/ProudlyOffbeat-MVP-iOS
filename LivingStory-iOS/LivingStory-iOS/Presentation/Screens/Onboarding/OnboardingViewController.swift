//
//  OnboardingViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  온보딩 화면 (런치스크린 → HomeKit 권한 요청)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  런치스크린과 동일한 검정 배경(.primary)으로 자연스럽게 이어지며,
//  HomeKitManager(서비스) 초기화를 통해 시스템 HomeKit 권한 다이얼로그를 표시한다.
//  권한 결과와 무관하게 메인 탭으로 전환한다.
//  (Home 탭이 자체적으로 권한 상태를 처리)
//

import UIKit

final class OnboardingViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    private var homeKitManager: HomeKitManager?
    
    override var backgroundStyle: ScreenBackgroundColor { .primary }
    
    // MARK: - UI Components

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NaruLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let subtitleLabel: UILabel = {
        let label = DynamicLabel()
        label.text = "나루, 이야기가 머무는 곳"
        label.font = .body2SemiBold
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logoImageView, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 44                  // ← 런치스크린 Spacing과 동일
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestHomeKitPermission()
    }
}

// MARK: - Setup

private extension OnboardingViewController {

    func setupStyle() {
        // 배경은 BaseViewController가 backgroundStyle(.primary)로 처리 → 여기서 따로 칠하지 않음
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupHierarchy() {
        view.addSubview(contentStackView)
    }

    func setupLayout() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),  // ← 런치스크린과 동일하게

            logoImageView.widthAnchor.constraint(equalToConstant: 150),                              // ← 런치스크린 Width와 동일
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor,
                                                  multiplier: 117.0 / 210.0)                          // 210:117 비율
        ])
    }
}

// MARK: - HomeKit Permission

private extension OnboardingViewController {

    /// HomeKitManager(서비스) 초기화로 권한 다이얼로그를 띄우고,
    /// 권한 결과(허용/거부)와 무관하게 메인으로 진입한다.
    func requestHomeKitPermission() {
        let manager = HomeKitManager()
        homeKitManager = manager
        manager.onHomesUpdated = { [weak self] _ in self?.proceedToMain() }
        manager.onPermissionDenied = { [weak self] in self?.proceedToMain() }

        // 이미 권한이 결정된 상태면 즉시 콜백 → 바로 진입
        manager.checkInitialStatus()
    }
}

// MARK: - Navigation

private extension OnboardingViewController {

    func proceedToMain() {
        // 중복 호출 방지
        guard homeKitManager != nil else { return }
        homeKitManager = nil

        UserData.hasCompletedOnboarding = true
        coordinator?.completeOnboarding()
    }
}
