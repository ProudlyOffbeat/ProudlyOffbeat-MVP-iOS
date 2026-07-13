//
//  EnvironmentSettingProfile.swift
//  LivingStory-iOS
//
//  첫 실행 세팅(아이 연령 설정)의 영속 도메인 모델.
//  - HomeKit의 구조/실시간 값은 저장하지 않는다 (앱 실행 시 HomeKit에서 fresh fetch).
//  - DB엔 "사용자가 정한 config"만: 선택한 집 / 활성화한 기기 / 아이 나이 / 읽어줄 시간.
//

import Foundation

struct EnvironmentSettingProfile: Equatable {
    var homeID: UUID
    var childAge: Int
    var readingHour: Int
    var readingMinute: Int
    var deviceConfigs: [DeviceConfig]

    /// 활성화된 기기 ID만 추출 (표시 시 HomeKit 트리와 병합용)
    func enabledDeviceIDs(of kind: HomeDeviceType) -> Set<UUID> {
        Set(deviceConfigs.filter { $0.kind == kind && $0.isEnabled }.map(\.deviceID))
    }
}

struct DeviceConfig: Equatable, Hashable {
    var deviceID: UUID   // HomeKit 액세서리 ID
    var roomID: UUID     // HomeKit 룸 ID
    var kind: HomeDeviceType
    var isEnabled: Bool
}
