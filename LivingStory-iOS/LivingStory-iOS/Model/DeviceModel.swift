//
//  DeviceModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import Foundation

// MARK: - DeviceModel

struct DeviceModel {
    let id: UUID
    let name: String
    let type: DeviceType
    var isOn: Bool
    var percentage: Int?
}

// MARK: - RoomModel

struct RoomModel {
    let id: UUID
    let name: String
    var devices: [DeviceModel]
}

// MARK: - HomeModel

struct HomeModel {
    let id: UUID
    let name: String
    var rooms: [RoomModel]
}

// MARK: - DeviceModel Helpers

extension DeviceModel {
    var statusText: String {
        guard isOn, let percentage = percentage else { return "Off" }
        return "\(percentage)%"
    }
}
