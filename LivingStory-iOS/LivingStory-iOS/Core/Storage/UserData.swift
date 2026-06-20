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
