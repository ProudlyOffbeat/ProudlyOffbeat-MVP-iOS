//
//  DeviceModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import Foundation

//MARK: - Device Model
struct DeviceModel: Hashable {
    var name: String
    let id: UUID
    var isOn: Bool
    var deviceType: HomeDeviceType
    var percentage: Int?
    
    // id가 같으면 같은 id
    static func == (lhs: DeviceModel, rhs: DeviceModel) -> Bool {
        lhs.id == rhs.id
    }
    
    // 해쉬 값도 id로만 만들기 -> Hashable 프로토콜
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension DeviceModel {
    var status: String {
        guard isOn, let percentage else { return "꺼짐" }
        return "\(percentage)"
    }
}
