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
    private(set) var activeReadingViewModel: ReadingViewModel?

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

        // Tab 3: 마이 (MyViewController → StatisticsView 교체)
        let myNav = UINavigationController()
        let myVC = UIHostingController(
            rootView: StatisticsView(coordinator: self, repository: ReadingSessionRepository())
        )
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
        hostingVC.hidesBottomBarWhenPushed = true
        activeNavigationController?.pushViewController(hostingVC, animated: true)
    }

    /// 독서 중 화면 (SwiftUI)
    func showReading(book: BookProfileModel) {
        let lightingController: any LightingControllable
        // 시뮬레이터엔 HomeKit이 없어 Mock, 실기기(Debug/Release 모두)는 실제 제어
        #if targetEnvironment(simulator)
        lightingController = MockLightingController()
        #else
        lightingController = HomeKitLightingController()
        #endif

        let viewModel = ReadingViewModel(
            book: book,
            lightingController: lightingController
        )
        activeReadingViewModel = viewModel
        UIApplication.shared.isIdleTimerDisabled = true
        let view = ReadingView(coordinator: self, viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: view)
        hostingVC.title = book.bookTitle
        hostingVC.navigationItem.largeTitleDisplayMode = .never
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    // MARK: - 마이 탭 네비게이션
    /// 책 읽기 완료 화면 (SwiftUI)
    func showStopReading(book: BookProfileModel, conversations: [ConversationProfile]) {
        let view = StopReadingView(coordinator: self, book: book, conversations: conversations)
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    /// 아이와 대화 나누기 화면 (SwiftUI)
    func showConversation(conversations: [ConversationProfile]) {
        let view = ConversationView(coordinator: self, conversations: conversations)
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    /// 독서 결과 화면 (SwiftUI)
    func showResult() {
        activeReadingViewModel = nil
        UIApplication.shared.isIdleTimerDisabled = false
        let view = ResultView(coordinator: self, repository: ReadingSessionRepository())
        let hostingVC = UIHostingController(rootView: view)
        (activeNavigationController ?? navigationController).pushViewController(hostingVC, animated: true)
    }

    /// 홈으로 돌아가기
    func popToHome() {
        activeNavigationController?.popToRootViewController(animated: true)
    }

    /// 현재 화면 위에 바코드 스캔 시트 재호출 (독서 플로우 중 "다른 책 스캔")
    func restartScanner() {
        guard let nav = activeNavigationController else { return }

        let vc = ScannerViewController()
        vc.coordinator = self
        vc.isRestarting = true

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [vc.scanningDetent]
            sheet.preferredCornerRadius = 32
        }

        // 현재 화면(StopReadingView) 위에 스캐너 present
        nav.topViewController?.present(vc, animated: true)
    }

    /// 기존 독서 스택 정리 후 새 책 BookProfileView로 교체
    func replaceReadingFlow(with book: BookProfileModel) {
        guard let nav = activeNavigationController else { return }
        // 루트(BookViewController)만 남기고 새 BookProfileView push
        let view = BookProfileView(coordinator: self, book: book)
        let hostingVC = UIHostingController(rootView: view)
        hostingVC.hidesBottomBarWhenPushed = true

        var viewControllers = [nav.viewControllers.first].compactMap { $0 }
        viewControllers.append(hostingVC)
        nav.setViewControllers(viewControllers, animated: true)
    }

    /// 통계 화면 (SwiftUI)
    func showStatistics() {
        let view = StatisticsView(coordinator: self, repository: ReadingSessionRepository())
        let hostingVC = UIHostingController(rootView: view)
        activeNavigationController?.pushViewController(hostingVC, animated: true)
    }

    // MARK: - 설정

    /// 설정 플로우 (SwiftUI) — 이 플로우만 SwiftUI NavigationStack(SettingsFlowView)이 네비바를 소유.
    /// UIKit 호스팅의 native large 타이틀 글리치 회피. 자식(나이·알림·집)은 SwiftUI 스택 내부에서 이동.
    func showSettings() {
        let hostingVC = NavBarHiddenHostingController(
            rootView: SettingsFlowView(coordinator: self)
        )
        // SwiftUI가 그리는 바 + UIDatePicker 등 UIKit 크롬을 다크로 (윈도우 Light 고정 무시). 탭바 숨김.
        hostingVC.overrideUserInterfaceStyle = .dark
        hostingVC.hidesBottomBarWhenPushed = true
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
