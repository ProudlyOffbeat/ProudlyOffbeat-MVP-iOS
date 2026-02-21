//
//  AppCoordinator.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit
import SwiftUI

final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private var tabBarController: MainTabBarController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        if UserData.hasCompletedOnboarding {
            setupTabBar()
        } else {
            showOnboarding()
        }
    }

    // MARK: - Tab Bar

    private func setupTabBar() {
        let tabBarController = MainTabBarController()

        // Tab 1: 환경 세팅
        let homeNav = UINavigationController()
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        homeNav.setViewControllers([homeVC], animated: false)
        homeNav.tabBarItem = UITabBarItem(
            title: StringLiterals.TabBar.home,
            image: UIImage(.home),
            tag: 0
        )

        // Tab 2: 책 읽기
        let bookNav = UINavigationController()
        let bookVC = BookViewController()
        bookVC.coordinator = self
        bookNav.setViewControllers([bookVC], animated: false)
        bookNav.tabBarItem = UITabBarItem(
            title: StringLiterals.TabBar.book,
            image: UIImage(.book),
            tag: 1
        )

        // Tab 3: 마이
        let myNav = UINavigationController()
        let myVC = MyViewController()
        myVC.coordinator = self
        myNav.setViewControllers([myVC], animated: false)
        myNav.tabBarItem = UITabBarItem(
            title: StringLiterals.TabBar.my,
            image: UIImage(.person),
            tag: 2
        )

        tabBarController.viewControllers = [homeNav, bookNav, myNav]
        tabBarController.selectedIndex = 1  // 기본 탭: 책 읽기

        self.tabBarController = tabBarController
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    // MARK: - 환경 세팅 탭 네비게이션

    /// 기기 검색 화면
    func showDeviceDiscovery() {
        let vc = DeviceDiscoveryViewController()
        vc.coordinator = self
        activeNavigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 책 읽기 탭 네비게이션

    /// 스캐너 화면 (바텀시트, 상태별 디텐트 전환)
    func showScanner() {
        let vc = ScannerViewController()
        vc.coordinator = self

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [vc.scanningDetent]
            sheet.preferredCornerRadius = 32
        }

        activeNavigationController?.present(vc, animated: true)
    }

    /// 책 프로필 화면 (SwiftUI)
    func showBookProfile(book: BookProfileModel) {
        let view = BookProfileView(coordinator: self, book: book)
        let hostingVC = UIHostingController(rootView: view)
        activeNavigationController?.pushViewController(hostingVC, animated: true)
    }

    /// 독서 중 화면 (SwiftUI)
    func showReading(book: BookProfileModel) {
        let lightingController: any LightingControllable
        #if DEBUG
        lightingController = MockLightingController()
        #else
        lightingController = HomeKitLightingController()
        #endif

        let viewModel = ReadingViewModel(
            book: book,
            lightingController: lightingController
        )
        let view = ReadingView(coordinator: self, viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    // MARK: - 마이 탭 네비게이션
    /// 독서 중단 화면 (SwiftUI)
    func showStopReading(bookTitle: String, conversations: [ConversationProfile]) {
        let view = StopReadingView(coordinator: self, bookTitle: bookTitle, conversations: conversations)
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    /// 독서 결과 화면 (SwiftUI)
    func showResult() {
        let view = ResultView(coordinator: self, repository: ReadingSessionRepository())
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    /// 홈으로 돌아가기
    func popToHome() {
        navigationController.popToRootViewController(animated: true)
    }

    /// 통계 화면 (SwiftUI)
    func showStatistics() {
        let view = StatisticsView(coordinator: self, repository: ReadingSessionRepository())
        let hostingVC = UIHostingController(rootView: view)
        activeNavigationController?.pushViewController(hostingVC, animated: true)
    }

    // MARK: - 공통

    /// 뒤로 가기
    func pop() {
        activeNavigationController?.popViewController(animated: true)
    }

    /// 온보딩 화면
    func showOnboarding() {
        let vc = OnboardingViewController()
        vc.coordinator = self
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([vc], animated: false)
    }

    /// 온보딩 완료 → 메인 탭 + 코치마크
    func completeOnboarding() {
        setupTabBar()
        showCoachMarks()
    }
}

// MARK: - Private Helpers

private extension AppCoordinator {
    /// 현재 활성화된 탭의 NavigationController
    var activeNavigationController: UINavigationController? {
        tabBarController?.selectedViewController as? UINavigationController
    }

    /// 코치마크 오버레이 표시
    func showCoachMarks() {
        guard let tabBarController,
              let window = navigationController.view.window else { return }

        let overlay = CoachMarkOverlayView(tabBar: tabBarController.tabBar)
        overlay.frame = window.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // "다음" 누르면 실제 탭 전환
        overlay.onTabSwitch = { [weak tabBarController] tabIndex in
            tabBarController?.selectedIndex = tabIndex
        }

        window.addSubview(overlay)
    }
}
