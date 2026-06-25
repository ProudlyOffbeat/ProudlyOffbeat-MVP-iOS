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
    private var pulseTask: Task<Void, Never>?

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

    /// 밝기 펄스 시작 (세팅 중 깜빡임 효과, UI 펄스와 동일한 2.5초 주기)
    /// 단계별로 부드럽게 밝기 변경 (예: 80→65→50→65→80)
    func startBrightnessPulse(base: Int = 80, range: Int = 50) async {
        pulseTask?.cancel()
        pulseTask = Task {
            let homes = (try? await ensureHomesLoaded()) ?? []
            let targetHome = homes.first(where: { !findLightServices(in: $0).isEmpty }) ?? homes.first
            guard let home = targetHome else { return }

            let brightChars = findLightServices(in: home).compactMap { service in
                service.characteristics.first { $0.characteristicType == HMCharacteristicTypeBrightness }
            }
            guard !brightChars.isEmpty else { return }

            let low = max(base - range, 10)
            let high = min(base + range, 100)
            let steps = 4 // 한 방향 단계 수
            let stepDelay: Double = 0.8 / Double(steps) // 0.8초 ÷ 4 = 0.2초 간격 (한 사이클 1.6초)

            while !Task.isCancelled {
                // 밝게 → 어둡게 (단계별)
                for i in 0...steps {
                    guard !Task.isCancelled else { return }
                    let brightness = high - (high - low) * i / steps
                    for char in brightChars {
                        try? await writeCharacteristic(char, value: brightness)
                    }
                    if i < steps {
                        try? await Task.sleep(for: .seconds(stepDelay))
                    }
                }
                // 어둡게 → 밝게 (단계별)
                for i in 0...steps {
                    guard !Task.isCancelled else { return }
                    let brightness = low + (high - low) * i / steps
                    for char in brightChars {
                        try? await writeCharacteristic(char, value: brightness)
                    }
                    if i < steps {
                        try? await Task.sleep(for: .seconds(stepDelay))
                    }
                }
            }
        }
    }

    /// 밝기 펄스 중지
    func stopBrightnessPulse() async {
        pulseTask?.cancel()
        pulseTask = nil
    }

    /// 조명이 꺼져있어도 H/S/B를 먼저 세팅한 뒤 전원을 켜서 색상 깜빡임 방지
    func applyLightingWithPowerOn(_ config: LightingConfig) async throws {
        let homes = try await ensureHomesLoaded()
        guard !homes.isEmpty else {
            throw HomeKitLightingError.noHomesAvailable
        }

        let targetHome = homes.first(where: { !findLightServices(in: $0).isEmpty })
            ?? homes[0]

        let lightServices = findLightServices(in: targetHome)
        guard !lightServices.isEmpty else {
            throw HomeKitLightingError.noLightsFound
        }

        var errors: [Error] = []
        for service in lightServices {
            do {
                try await writeLightingValuesThenPower(config, to: service)
            } catch {
                errors.append(error)
                print("[HomeKit] 조명 적용 실패: \(error.localizedDescription)")
            }
        }

        if errors.count == lightServices.count {
            throw HomeKitLightingError.noLightsFound
        }

        print("[HomeKit] 조명 적용 완료 (PowerOn) - H\(config.hue) S\(config.saturation) B\(config.brightness), \(lightServices.count - errors.count)/\(lightServices.count)개 성공")
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitLightingController: HMHomeManagerDelegate {

    nonisolated func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Task { @MainActor in
            self.resumeHomesContinuation(with: manager.homes)
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
                await withTaskCancellationHandler {
                    await withCheckedContinuation { continuation in
                        self.homesLoadedContinuation = continuation
                    }
                } onCancel: {
                    // 타임아웃/취소 시에도 continuation을 반드시 resume → 누수 방지
                    Task { @MainActor in self.resumeHomesContinuation(with: []) }
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

    /// continuation을 한 번만 resume (delegate·취소 양쪽에서 호출, 중복 resume 방지)
    func resumeHomesContinuation(with homes: [HMHome]) {
        guard let continuation = homesLoadedContinuation else { return }
        homesLoadedContinuation = nil
        continuation.resume(returning: homes)
    }

    /// 집 안의 모든 조명 서비스 찾기
    func findLightServices(in home: HMHome) -> [HMService] {
        home.accessories.compactMap { accessory in
            accessory.services.first { $0.serviceType == HMServiceTypeLightbulb }
        }
    }

    /// 조명 서비스에 전원 켜기 → HSB 값 쓰기 (기존 방식)
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

    /// HSB를 먼저 세팅한 뒤 전원을 켜서 색상 깜빡임 방지
    func writeLightingValuesThenPower(_ config: LightingConfig, to service: HMService) async throws {
        // 1. 색상/채도/밝기 먼저 세팅 (전원 끈 상태에서도 값은 쓸 수 있음)
        if let hueChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeHue
        }) {
            try await writeCharacteristic(hueChar, value: Float(config.hue))
        }

        if let satChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeSaturation
        }) {
            try await writeCharacteristic(satChar, value: Float(config.saturation))
        }

        if let brightChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypeBrightness
        }) {
            try await writeCharacteristic(brightChar, value: config.brightness)
        }

        // 2. 마지막에 전원 켜기 → 세팅된 색상으로 바로 켜짐
        if let powerChar = service.characteristics.first(where: {
            $0.characteristicType == HMCharacteristicTypePowerState
        }) {
            try await writeCharacteristic(powerChar, value: true)
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
