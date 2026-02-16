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
    var isOn: Bool
    var deviceType: HomeDeviceType
    var percentage: Int?
    
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
        guard isOn, let percentage else { return StringLiterals.Home.deviceOff }
        return "\(percentage)%"
    }
}
