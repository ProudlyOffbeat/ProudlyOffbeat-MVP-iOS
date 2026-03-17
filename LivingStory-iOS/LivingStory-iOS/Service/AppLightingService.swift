//
//  AppLightingService.swift
//  LivingStory-iOS
//
//  앱 라이프사이클에 따른 조명 관리
//  - 앱 실행 시: 디폴트 색상 적용 (꺼져있으면 켜기)
//  - 백그라운드 진입: 기본 색상(흰색)으로 복원
//  - 포그라운드 복귀: 디폴트 색상 재적용
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

    /// 앱 시작/포그라운드 복귀 시 호출 — 디폴트 조명 적용 (꺼져있으면 켜기)
    func applyDefaultLighting() {
        Task {
            do {
                try await lightingController.applyLightingWithPowerOn(.default)
                print("[AppLighting] 디폴트 조명 적용 완료")
            } catch {
                print("[AppLighting] 디폴트 조명 적용 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 백그라운드 진입 시 호출 — 디폴트 색상으로 복원
    func restoreDefault() {
        Task {
            do {
                try await lightingController.applyLighting(.default)
                print("[AppLighting] 디폴트 복원 완료")
            } catch {
                print("[AppLighting] 디폴트 복원 실패: \(error.localizedDescription)")
            }
        }
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
