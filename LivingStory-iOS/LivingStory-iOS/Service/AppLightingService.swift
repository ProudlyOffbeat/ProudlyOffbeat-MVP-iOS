//
//  AppLightingService.swift
//  LivingStory-iOS
//
//  앱 라이프사이클에 따른 조명 관리
//  - 앱 실행/포그라운드 복귀: 마지막으로 사용된 조명 적용 (없으면 디폴트)
//  - 백그라운드 진입: 조명 그대로 유지 (마지막 상태 보존)
//

import UIKit

@MainActor
final class AppLightingService {

    static let shared = AppLightingService()

    /// 독서 중이면 true — 백그라운드/포그라운드 조명 변경 스킵
    var isReadingActive = false

    private let lightingController: any LightingControllable

    private init() {
        #if DEBUG
        lightingController = MockLightingController()
        #else
        lightingController = HomeKitLightingController()
        #endif
    }

    // MARK: - Lifecycle

    /// 앱 시작/포그라운드 복귀 시 호출 (꺼져있으면 켜기 포함)
    /// - 최초 진입: `.default` 적용 (UserData 에 저장 없음)
    /// - 이후: 마지막으로 적용된 조명 복원
    func applyDefaultLighting() {
        let config = UserData.lastLightingConfig ?? .default
        let isFirstLaunch = UserData.lastLightingConfig == nil
        Task {
            do {
                try await lightingController.applyLightingWithPowerOn(config)
                if isFirstLaunch {
                    print("[AppLighting] 최초 진입 — 디폴트 조명 적용")
                } else {
                    print("[AppLighting] 마지막 조명 복원 — H\(config.hue) S\(config.saturation) B\(config.brightness)")
                }
            } catch {
                print("[AppLighting] 조명 적용 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 백그라운드 진입 시 호출 — 조명 그대로 유지 (no-op)
    /// 마지막 사용자 조명을 백그라운드에서도 보존, 포그라운드 복귀 시 동일 상태 유지
    func restoreDefault() {
        // 의도적으로 비워둠 — 백그라운드 진입 시 조명 상태 보존
    }

    // MARK: - Observer Setup

    func registerLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func handleDidBecomeActive() {
        guard !isReadingActive else { return }
        applyDefaultLighting()
    }

    @objc private func handleDidEnterBackground() {
        guard !isReadingActive else { return }
        restoreDefault()
    }
}
