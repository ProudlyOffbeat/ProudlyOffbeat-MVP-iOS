//
//  HomeKitLightingController.swift
//  LivingStory-iOS
//

import HomeKit

// MARK: - Error

enum HomeKitLightingError: LocalizedError, Sendable {
    case noHomesAvailable
    case noLightsFound
    case characteristicWriteFailed(String)
    case homeLoadTimeout

    var errorDescription: String? {
        switch self {
        case .noHomesAvailable:
            return "HomeKit에 등록된 집이 없습니다."
        case .noLightsFound:
            return "제어 가능한 조명을 찾을 수 없습니다."
        case .characteristicWriteFailed(let detail):
            return "조명 값 쓰기 실패: \(detail)"
        case .homeLoadTimeout:
            return "HomeKit 집 데이터 로드 시간 초과"
        }
    }
}

// MARK: - Controller

@MainActor
final class HomeKitLightingController: NSObject, LightingControllable {

    // MARK: - Properties

    private let homeManager = HMHomeManager()
    private var homesLoadedContinuation: CheckedContinuation<[HMHome], Never>?

    // MARK: - Init

    override init() {
        super.init()
        homeManager.delegate = self
    }

    // MARK: - LightingControllable

    func applyLighting(_ config: LightingConfig) async throws {
        let homes = try await ensureHomesLoaded()
        guard !homes.isEmpty else {
            throw HomeKitLightingError.noHomesAvailable
        }

        // 조명이 있는 집 우선, 없으면 첫 번째 집 fallback
        let targetHome = homes.first(where: { !findLightServices(in: $0).isEmpty })
            ?? homes[0]

        let lightServices = findLightServices(in: targetHome)
        guard !lightServices.isEmpty else {
            throw HomeKitLightingError.noLightsFound
        }

        // Best-effort: 가능한 만큼 적용, 전부 실패 시만 throw
        var errors: [Error] = []
        for service in lightServices {
            do {
                try await writeLightingValues(config, to: service)
            } catch {
                errors.append(error)
                print("[HomeKit] 조명 적용 실패: \(error.localizedDescription)")
            }
        }

        if errors.count == lightServices.count {
            throw HomeKitLightingError.noLightsFound
        }

        print("[HomeKit] 조명 적용 완료 - H\(config.hue) S\(config.saturation) B\(config.brightness), \(lightServices.count - errors.count)/\(lightServices.count)개 성공")
    }

    func resetLighting() async throws {
        try await applyLighting(.default)
        print("[HomeKit] 조명 리셋 완료 (기본값)")
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitLightingController: HMHomeManagerDelegate {

    nonisolated func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Task { @MainActor in
            if let continuation = homesLoadedContinuation {
                homesLoadedContinuation = nil
                continuation.resume(returning: manager.homes)
            }
        }
    }
}

// MARK: - Private

private extension HomeKitLightingController {

    /// HMHomeManager의 homes가 로드될 때까지 대기 (타임아웃 10초)
    func ensureHomesLoaded() async throws -> [HMHome] {
        if !homeManager.homes.isEmpty {
            return homeManager.homes
        }

        return try await withThrowingTaskGroup(of: [HMHome].self) { group in
            group.addTask { @MainActor in
                await withCheckedContinuation { continuation in
                    self.homesLoadedContinuation = continuation
                }
            }
            group.addTask {
                try await Task.sleep(for: .seconds(10))
                throw HomeKitLightingError.homeLoadTimeout
            }

            let result = try await group.next() ?? []
            group.cancelAll()
            return result
        }
    }

    /// 집 안의 모든 조명 서비스 찾기
    func findLightServices(in home: HMHome) -> [HMService] {
        home.accessories.compactMap { accessory in
            accessory.services.first { $0.serviceType == HMServiceTypeLightbulb }
        }
    }

    /// 조명 서비스에 HSB + 전원 값 쓰기
    func writeLightingValues(_ config: LightingConfig, to service: HMService) async throws {
        // 전원 켜기
        if let powerChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypePowerState
        }) {
            try await writeCharacteristic(powerChar, value: true)
        }

        // 색상 (Hue) - 지원하는 조명만
        if let hueChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeHue
        }) {
            try await writeCharacteristic(hueChar, value: Float(config.hue))
        }

        // 채도 (Saturation) - 지원하는 조명만
        if let satChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeSaturation
        }) {
            try await writeCharacteristic(satChar, value: Float(config.saturation))
        }

        // 밝기 (Brightness) - 거의 모든 조명이 지원
        if let brightChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeBrightness
        }) {
            try await writeCharacteristic(brightChar, value: config.brightness)
        }
    }

    /// HMCharacteristic.writeValue completion handler를 async로 래핑
    func writeCharacteristic(_ characteristic: HMCharacteristic, value: Any) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            characteristic.writeValue(value) { error in
                if let error {
                    continuation.resume(throwing: HomeKitLightingError.characteristicWriteFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
