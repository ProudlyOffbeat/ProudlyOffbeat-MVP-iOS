//
//  LightingConfig.swift
//  LivingStory-iOS
//

import Foundation

struct LightingConfig: Codable, Sendable {
    /// 색상 (0~360)
    let hue: Int
    /// 채도 (0~100)
    let saturation: Int
    /// 밝기 (0~100)
    let brightness: Int

    /// 앱 기본 조명 (따뜻한 백색) — 앱 실행/독서 종료/백그라운드 복원 공용
    static let `default` = LightingConfig(hue: 40, saturation: 20, brightness: 80)
}

/// HomeKit 조명 제어 인터페이스
protocol LightingControllable {
    func applyLighting(_ config: LightingConfig) async throws
    func resetLighting() async throws
    func applyLightingWithPowerOn(_ config: LightingConfig) async throws
    func startBrightnessPulse(base: Int, range: Int) async
    func stopBrightnessPulse() async
}

#if DEBUG
struct MockLightingController: LightingControllable {
    func applyLighting(_ config: LightingConfig) async throws {
        print("[MockLighting] 조명 적용 - H\(config.hue) S\(config.saturation) B\(config.brightness)")
    }

    func resetLighting() async throws {
        print("[MockLighting] 조명 리셋")
    }

    func applyLightingWithPowerOn(_ config: LightingConfig) async throws {
        print("[MockLighting] 조명 켜기 + 적용 - H\(config.hue) S\(config.saturation) B\(config.brightness)")
    }

    func startBrightnessPulse(base: Int, range: Int) async {
        print("[MockLighting] 밝기 펄스 시작 (base: \(base), range: \(range))")
    }

    func stopBrightnessPulse() async {
        print("[MockLighting] 밝기 펄스 중지")
    }
}
#endif
