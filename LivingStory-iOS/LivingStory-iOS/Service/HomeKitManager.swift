//
//  HomeKitManager.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import HomeKit

final class HomeKitManager: NSObject {

    // MARK: - Properties

    private let homeManager = HMHomeManager()
    private var pendingUpdateTask: Task<Void, Never>?

    /// HomeKit에서 집 목록이 업데이트되면 호출되는 콜백
    var onHomesUpdated: (([HomeModel]) -> Void)?

    /// HomeKit 권한이 거부되었을 때 호출되는 콜백
    var onPermissionDenied: (() -> Void)?

    // MARK: - Init

    override init() {
        super.init()
        homeManager.delegate = self
    }

    /// 콜백 설정 후 호출 — 이미 권한이 결정된 상태면 즉시 콜백 실행
    func checkInitialStatus() {
        let status = homeManager.authorizationStatus
        if status.contains(.determined) {
            handleStatus(status)
        }
    }

    /// 모든 구독 대상 특성의 최신 값을 HomeKit에서 읽어옴 (포그라운드 복귀 시 호출)
    func refreshAllCharacteristics() async {
        let subscribableTypes: Set<String> = [
            HMCharacteristicTypePowerState,
            HMCharacteristicTypeBrightness,
            HMCharacteristicTypeVolume
        ]

        let characteristics = homeManager.homes
            .flatMap(\.rooms)
            .flatMap(\.accessories)
            .flatMap(\.services)
            .flatMap(\.characteristics)
            .filter { subscribableTypes.contains($0.characteristicType) }

        await withTaskGroup(of: Void.self) { group in
            for characteristic in characteristics {
                group.addTask {
                    try? await characteristic.readValue()
                }
            }
        }
    }
}

extension HomeKitManager: HMHomeDelegate {
    
    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        accessory.delegate = self

        Task {
            await enableNotifications(for: accessory)

            let homes = homeManager.homes.map { mapHome($0) }
            await MainActor.run {
                onHomesUpdated?(homes)
            }
        }
    }

    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        Task {
            let homes = homeManager.homes.map { mapHome($0) }
            await MainActor.run {
                onHomesUpdated?(homes)
            }
        }
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitManager: HMHomeManagerDelegate {

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        handleStatus(manager.authorizationStatus)
    }

    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        if status.contains(.determined) {
            handleStatus(status)
        }
    }
}

// MARK: - Status Handling

private extension HomeKitManager {

    func handleStatus(_ status: HMHomeManagerAuthorizationStatus) {
        guard status.contains(.authorized) else {
            Task { @MainActor in
                onPermissionDenied?()
            }
            return
        }

        Task {
            for home in homeManager.homes {
                await registerForNotifications(in: home)
            }

            let homes = homeManager.homes.map { mapHome($0) }
            await MainActor.run {
                onHomesUpdated?(homes)
            }
        }
    }
}

// MARK: - HMAccessoryDelegate

extension HomeKitManager: HMAccessoryDelegate {

    /// 액세서리의 특성 값이 변경되면 호출 (외부 앱, 자동화, 물리 제어 등)
    func accessory(_ accessory: HMAccessory, service: HMService,
                   didUpdateValueFor characteristic: HMCharacteristic) {
        print("[HomeKit] 특성 변경 감지: \(accessory.name) - \(characteristic.characteristicType) = \(String(describing: characteristic.value))")
        // 디바운싱: 150ms 내 연속 변경을 최종 1회로 합침 (밝기 슬라이더 등)
        pendingUpdateTask?.cancel()
        pendingUpdateTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            let homes = homeManager.homes.map { mapHome($0) }
            onHomesUpdated?(homes)
        }
    }
}

// MARK: - Private Mapping

private extension HomeKitManager {

    // MARK: - Notification Registration

    /// 집 안 모든 액세서리에 delegate 설정 + 특성 변경 알림 구독
    func registerForNotifications(in home: HMHome) async {
        home.delegate = self
        for room in home.rooms {
            for accessory in room.accessories {
                accessory.delegate = self
                await enableNotifications(for: accessory)
            }
        }
    }

    /// 특성 값 변경 이벤트 알림 활성화 (전원, 밝기, 볼륨)
    func enableNotifications(for accessory: HMAccessory) async {
        let subscribableTypes: Set<String> = [
            HMCharacteristicTypePowerState,
            HMCharacteristicTypeBrightness,
            HMCharacteristicTypeVolume
        ]
        for service in accessory.services {
            for characteristic in service.characteristics where
                subscribableTypes.contains(characteristic.characteristicType) &&
                characteristic.properties.contains(HMCharacteristicPropertySupportsEventNotification) {
                do {
                    try await characteristic.enableNotification(true)
                } catch {
                    print("[HomeKit] 알림 활성화 실패 (\(accessory.name)): \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Mapping

    /// HMHome → HomeModel 변환
    func mapHome(_ hmHome: HMHome) -> HomeModel {
        let rooms = hmHome.rooms.map { mapRoom($0) }
        let hasDevices = rooms.contains { !$0.devices.isEmpty }
        return HomeModel(
            id: hmHome.uniqueIdentifier,
            name: hmHome.name,
            state: hasDevices ? .normal : .noDevices,
            rooms: rooms
        )
    }

    /// HMRoom → RoomModel 변환
    func mapRoom(_ hmRoom: HMRoom) -> RoomModel {
        let devices = hmRoom.accessories.compactMap { mapAccessory($0) }
        return RoomModel(
            name: hmRoom.name,
            id: hmRoom.uniqueIdentifier,
            devices: devices
        )
    }

    /// HMAccessory → DeviceModel 변환 (조명/스피커만 필터링)
    func mapAccessory(_ accessory: HMAccessory) -> DeviceModel? {
        // 조명 서비스 찾기
        if let lightService = accessory.services.first(where: {
            $0.serviceType == HMServiceTypeLightbulb
        }) {
            return mapLightDevice(accessory: accessory, service: lightService)
        }

        // 스피커 서비스 찾기
        if accessory.services.contains(where: {
            $0.serviceType == HMServiceTypeSpeaker
        }) {
            return mapSpeakerDevice(accessory: accessory)
        }

        return nil
    }

    /// 조명 기기 매핑
    func mapLightDevice(accessory: HMAccessory, service: HMService) -> DeviceModel {
        var isOn = false
        var brightness: Int?

        for characteristic in service.characteristics {
            switch characteristic.characteristicType {
            case HMCharacteristicTypePowerState:
                isOn = (characteristic.value as? Bool) ?? false
            case HMCharacteristicTypeBrightness:
                brightness = characteristic.value as? Int
            default:
                break
            }
        }

        return DeviceModel(
            name: accessory.name,
            id: accessory.uniqueIdentifier,
            isOn: isOn,
            deviceType: .light,
            percentage: brightness
        )
    }

    /// 스피커 기기 매핑
    func mapSpeakerDevice(accessory: HMAccessory) -> DeviceModel {
        var isOn = false
        var volume: Int?

        for service in accessory.services {
            for characteristic in service.characteristics {
                switch characteristic.characteristicType {
                case HMCharacteristicTypePowerState:
                    isOn = (characteristic.value as? Bool) ?? false
                case HMCharacteristicTypeVolume:
                    volume = characteristic.value as? Int
                default:
                    break
                }
            }
        }

        return DeviceModel(
            name: accessory.name,
            id: accessory.uniqueIdentifier,
            isOn: isOn,
            deviceType: .speaker,
            percentage: volume
        )
    }
}
