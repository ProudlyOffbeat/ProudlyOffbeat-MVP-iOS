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
//  런치스크린과 동일한 배경(yellow0)으로 자연스럽게 이어지며,
//  HMHomeManager 초기화를 통해 시스템 HomeKit 권한 다이얼로그를 표시한다.
//  권한 결과와 무관하게 메인 탭으로 전환한다.
//  (Home 탭이 자체적으로 권한 상태를 처리)
//

import UIKit
import HomeKit

final class OnboardingViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    private var homeManager: HMHomeManager?

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
        view.backgroundColor = UIColor(named: "yellow0")
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupHierarchy() {
        view.addSubview(logoImageView)
        view.addSubview(subtitleLabel)
    }

    func setupLayout() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 14)
        ])
    }
}

// MARK: - HomeKit Permission

private extension OnboardingViewController {

    func requestHomeKitPermission() {
        let manager = HMHomeManager()
        homeManager = manager
        manager.delegate = self

        // 이미 권한이 결정된 상태면 delegate가 안 올 수 있으므로 바로 진입
        let status = manager.authorizationStatus
        if status.contains(.determined) {
            proceedToMain()
        }
    }
}

// MARK: - HMHomeManagerDelegate

extension OnboardingViewController: HMHomeManagerDelegate {

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        proceedToMain()
    }

    /// 권한 상태 변경 시 호출 (거부 시 homeManagerDidUpdateHomes가 안 올 수 있음)
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        if status.contains(.determined) {
            proceedToMain()
        }
    }
}

// MARK: - Navigation

private extension OnboardingViewController {

    func proceedToMain() {
        // 중복 호출 방지
        guard homeManager != nil else { return }
        homeManager?.delegate = nil
        homeManager = nil

        UserData.hasCompletedOnboarding = true
        coordinator?.completeOnboarding()
    }
}
