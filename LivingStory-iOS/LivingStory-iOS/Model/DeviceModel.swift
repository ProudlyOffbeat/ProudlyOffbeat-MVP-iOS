//
//  DeviceModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import Foundation

//MARK: - Device Model
nonisolated struct DeviceModel: Hashable, Sendable {
    var name: String
    let id: UUID
    /// HomeKit이 보고한 실제 전원 상태 (authoritative)
    var isOn: Bool
    var deviceType: HomeDeviceType
    var percentage: Int?

    /// 옵티미스틱 목표값 — 사용자가 탭한 순간의 의도. 쓰기 진행 중에만 값이 있고, 확정/롤백되면 nil.
    /// UI는 항상 이 값을 우선 반영하고(`displayIsOn`), 실제 응답이 오면 확정하거나 되돌린다.
    var pendingIsOn: Bool?

    /// UI가 그려야 할 전원 상태 — 진행 중이면 목표값, 아니면 실제값.
    var displayIsOn: Bool { pendingIsOn ?? isOn }

    /// 쓰기 응답을 기다리는 중인지 (셀의 "적용 중" 표시에 사용).
    var isPending: Bool { pendingIsOn != nil }

    // id가 같으면 같은 id
    nonisolated static func == (lhs: DeviceModel, rhs: DeviceModel) -> Bool {
        lhs.id == rhs.id
    }

    // 해쉬 값도 id로만 만들기 -> Hashable 프로토콜
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension DeviceModel {
    var status: String {
        guard displayIsOn else { return StringLiterals.Home.deviceOff }
        // 켜짐이지만 밝기/볼륨을 아직 모를 때(옵티미스틱 순간)는 "켜짐"으로.
        guard let percentage else { return StringLiterals.Home.deviceOn }
        return "\(percentage)%"
    }
}
