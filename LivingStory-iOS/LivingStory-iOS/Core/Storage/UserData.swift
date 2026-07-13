//
//  UserData.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//

import Foundation

struct UserData {
    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    static var hasCompletedOnboarding: Bool

    // MARK: - 사용자 설정값 (직접 입력 → 영속화)

    /// 아이 나이(세). 독서 질문 연령 기준에 사용. 기본 6세(독서 플로우 기본값과 일치).
    @UserDefault(key: "childAge", defaultValue: 6)
    static var childAge: Int

    /// 취침 독서 알림 on/off
    @UserDefault(key: "notificationEnabled", defaultValue: true)
    static var notificationEnabled: Bool

    /// 알림 시간. 기본 오후 9:30. (실제 알림 등록은 추후 작업)
    @UserDefault(key: "notificationTime", defaultValue: UserData.defaultNotificationTime)
    static var notificationTime: Date

    /// 알림 시간 기본값(21:30) — 시/분만 의미 있음
    private static let defaultNotificationTime: Date = {
        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? Date()
    }()

    // 마지막으로 적용된 조명 (없으면 hue = -1)
    @UserDefault(key: "lastLightingHue", defaultValue: -1)
    static var lastLightingHue: Int

    @UserDefault(key: "lastLightingSaturation", defaultValue: -1)
    static var lastLightingSaturation: Int

    @UserDefault(key: "lastLightingBrightness", defaultValue: -1)
    static var lastLightingBrightness: Int

    /// 마지막으로 적용된 조명 설정
    /// - 최초 진입: `nil` 반환 → 호출자가 `.default` 로 fallback
    /// - 이후: 사용자가 마지막으로 적용했던 값 반환
    static var lastLightingConfig: LightingConfig? {
        get {
            guard lastLightingHue >= 0 else { return nil }
            return LightingConfig(
                hue: lastLightingHue,
                saturation: lastLightingSaturation,
                brightness: lastLightingBrightness
            )
        }
        set {
            if let newValue {
                lastLightingHue = newValue.hue
                lastLightingSaturation = newValue.saturation
                lastLightingBrightness = newValue.brightness
            } else {
                lastLightingHue = -1
                lastLightingSaturation = -1
                lastLightingBrightness = -1
            }
        }
    }
}
