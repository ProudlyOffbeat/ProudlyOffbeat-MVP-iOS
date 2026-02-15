//
//  RoomModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/12/26.
//

import Foundation

nonisolated struct RoomModel: Hashable, Sendable {
    var name: String
    let id: UUID
    var devices: [DeviceModel]

    nonisolated static func == (lhs: RoomModel, rhs: RoomModel) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
