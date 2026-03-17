//
//  SceneDelegate.swift
//  LivingStory-iOS
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()

        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        // 앱 라이프사이클에 따른 조명 관리 시작 (didBecomeActive에서 디폴트 적용)
        AppLightingService.shared.registerLifecycleObservers()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
