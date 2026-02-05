//
//  OnboardingViewController.swift
//  LivingStory-iOS
//
//  🧑‍💻 담당: 데미안 (UIKit)
//

import UIKit

final class OnboardingViewController: UIViewController {

    weak var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "blue0")
        title = "온보딩"
    }

    private func setupLayout() {
        // TODO: 3페이지 슬라이드 레이아웃
    }

    private func setupActions() {
        // TODO: 다음/시작하기 버튼
    }
}

// MARK: - Preview

#Preview {
    OnboardingViewController()
}
