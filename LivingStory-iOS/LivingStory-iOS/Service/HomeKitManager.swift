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

        let homes = homeManager.homes.map { mapHome($0) }
        DispatchQueue.main.async { [weak self] in
            self?.onHomesUpdated?(homes)
        }
    }
}

// MARK: - Private Mapping

private extension HomeKitManager {

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
