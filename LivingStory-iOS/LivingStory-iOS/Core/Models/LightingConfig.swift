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

/// 독서 분위기 프리셋 — 탭 한 번으로 1 write (슬라이더 대체)
enum LightingPreset: String, CaseIterable, Sendable {
    case focus = "집중"
    case warm = "따뜻"
    case relax = "휴식"
    case emotion = "감성"
    case cool = "차분"

    var config: LightingConfig {
        switch self {
        case .focus:   return LightingConfig(hue: 210, saturation: 15, brightness: 100)  // 쿨 화이트
        case .warm:    return LightingConfig(hue: 30,  saturation: 70, brightness: 85)   // 앰버
        case .relax:   return LightingConfig(hue: 20,  saturation: 55, brightness: 65)   // 따뜻 오렌지
        case .emotion: return LightingConfig(hue: 280, saturation: 60, brightness: 55)   // 은은한 퍼플
        case .cool:    return LightingConfig(hue: 200, saturation: 20, brightness: 90)   // 시원한 화이트
        }
    }
}

/// HomeKit 조명 제어 인터페이스
protocol LightingControllable {
    func applyLighting(_ config: LightingConfig) async throws
    func resetLighting() async throws
    func applyLightingWithPowerOn(_ config: LightingConfig) async throws
    func startBrightnessPulse(base: Int, range: Int) async
    func stopBrightnessPulse() async
}

// 시뮬레이터엔 HomeKit이 없어 Release+시뮬 빌드에서도 필요 → DEBUG뿐 아니라 simulator에서도 컴파일.
// (실기기 Release에선 제외 — AppCoordinator가 HomeKitLightingController 사용)
#if DEBUG || targetEnvironment(simulator)
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
