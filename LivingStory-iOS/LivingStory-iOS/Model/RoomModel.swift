//
//  RoomModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/12/26.
//

import Foundation

struct RoomModel {
    var name: String
    let id: UUID
    var devices: [DeviceModel]
}
