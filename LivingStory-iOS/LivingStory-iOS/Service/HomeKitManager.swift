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
    private var pendingUpdateWorkItem: DispatchWorkItem?

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
            DispatchQueue.main.async { [weak self] in
                self?.onPermissionDenied?()
            }
            return
        }

        for home in homeManager.homes {
            registerForNotifications(in: home)
        }

        let homes = homeManager.homes.map { mapHome($0) }
      
        DispatchQueue.main.async { [weak self] in
            self?.onHomesUpdated?(homes)
        }
    }
}

// MARK: - HMAccessoryDelegate

extension HomeKitManager: HMAccessoryDelegate {

    /// 액세서리의 특성 값이 변경되면 호출 (외부 앱, 자동화, 물리 제어 등)
    func accessory(_ accessory: HMAccessory, service: HMService,
                   didUpdateValueFor characteristic: HMCharacteristic) {
        // 디바운싱: 150ms 내 연속 변경을 최종 1회로 합침 (밝기 슬라이더 등)
        pendingUpdateWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let homes = self.homeManager.homes.map { self.mapHome($0) }
            self.onHomesUpdated?(homes)
        }
        pendingUpdateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }
}

// MARK: - Private Mapping

private extension HomeKitManager {

    // MARK: - Notification Registration

    /// 집 안 모든 액세서리에 delegate 설정 + 특성 변경 알림 구독
    func registerForNotifications(in home: HMHome) {
        for room in home.rooms {
            for accessory in room.accessories {
                accessory.delegate = self
                enableNotifications(for: accessory)
            }
        }
    }

    /// 특성 값 변경 이벤트 알림 활성화 (전원, 밝기, 볼륨)
    func enableNotifications(for accessory: HMAccessory) {
        let subscribableTypes: Set<String> = [
            HMCharacteristicTypePowerState,
            HMCharacteristicTypeBrightness,
            HMCharacteristicTypeVolume
        ]
        for service in accessory.services {
            for characteristic in service.characteristics where
                subscribableTypes.contains(characteristic.characteristicType) &&
                characteristic.properties.contains(HMCharacteristicPropertySupportsEventNotification) {
                characteristic.enableNotification(true) { error in
                    if let error {
                        print("[HomeKit] 알림 활성화 실패 (\(accessory.name)): \(error.localizedDescription)")
                    }
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
