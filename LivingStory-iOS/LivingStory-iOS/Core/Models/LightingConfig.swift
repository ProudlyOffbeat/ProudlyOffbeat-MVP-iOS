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

    /// 독서 종료 시 리셋 기본값 (따뜻한 백색)
    static let `default` = LightingConfig(hue: 40, saturation: 20, brightness: 80)
}

/// HomeKit 조명 제어 인터페이스 (Demian 구현 예정)
protocol LightingControllable {
    func applyLighting(_ config: LightingConfig) async throws
    func resetLighting() async throws
}

#if DEBUG
struct MockLightingController: LightingControllable {
    func applyLighting(_ config: LightingConfig) async throws {
        print("[MockLighting] 조명 적용 - H\(config.hue) S\(config.saturation) B\(config.brightness)")
    }

    func resetLighting() async throws {
        print("[MockLighting] 조명 리셋")
    }
}
#endif
