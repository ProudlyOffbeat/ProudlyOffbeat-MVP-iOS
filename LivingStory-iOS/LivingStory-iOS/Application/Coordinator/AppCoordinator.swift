//
//  AppCoordinator.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 화면 담당
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  🧑‍💻 데미안 (UIKit)          📱 이토 (SwiftUI)
//  ─────────────────────────  ─────────────────────────
//  • 온보딩                    • 책 프로필
//  • 홈                        • 독서 중
//  • 스캐너                    • 통계
//  • 기기 검색
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 UIKit vs SwiftUI 화면 전환
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  UIKit 화면 이동:
//  ```swift
//  let vc = SomeViewController()
//  navigationController.pushViewController(vc, animated: true)
//  ```
//
//  SwiftUI 화면 이동:
//  ```swift
//  let swiftUIView = SomeSwiftUIView()
//  let hostingVC = UIHostingController(rootView: swiftUIView)
//  navigationController.pushViewController(hostingVC, animated: true)
//  ```
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit
import SwiftUI

final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showHome()
    }

    // MARK: - 🧑‍💻 데미안 담당 (UIKit)

    /// 홈 화면
    func showHome() {
        let vc = HomeViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    /// 온보딩 화면
    func showOnboarding() {
        let vc = OnboardingViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    /// 스캐너 화면
    func showScanner() {
        let vc = ScannerViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    /// 기기 검색 화면
    func showDeviceDiscovery() {
        let vc = DeviceDiscoveryViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - 📱 이토 담당 (SwiftUI)

    /// 책 프로필 화면 (SwiftUI)
    func showBookProfile(book: BookProfileModel) {
        let view = BookProfileView(coordinator: self, book: book)
        let hostingVC = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingVC, animated: true)
    }

    /// 독서 중 화면 (SwiftUI)
    func showReading(book: BookProfileModel) {
        let viewModel = ReadingViewModel(book: book)
        let view = ReadingView(coordinator: self, viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingVC, animated: true)
    }

    /// 통계 화면 (SwiftUI)
    func showStatistics() {
        let view = StatisticsView(coordinator: self)
        let hostingVC = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingVC, animated: true)
    }

    // MARK: - 공통

    /// 뒤로 가기
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
