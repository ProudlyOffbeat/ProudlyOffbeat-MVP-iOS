//
//  AppDelegate.swift
//  LivingStory-iOS
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// 앱당 단일 홈 데이터 소스(= HMHomeManager 1개). 프로세스당 1개인 AppDelegate가 소유해
    /// scene 재연결·멀티윈도우와 무관하게 단일성을 보장한다. lazy라 첫 접근(온보딩) 전엔 생성 안 됨
    /// → 권한 다이얼로그 타이밍 보존. didFinishLaunching에서는 절대 접근하지 않는다.
    lazy var homeProvider: HomeDataProviding = HomeProviderFactory.make()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        #if DEBUG
        StreakDataSeeder.seedIfNeeded()   // -SeedStreakData 실행 시에만 동작
        #endif
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {

    }

    // MARK: - Orientation Lock

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
