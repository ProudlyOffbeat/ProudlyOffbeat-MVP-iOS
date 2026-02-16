//
//  HomeModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/12/26.
//

import Foundation

struct HomeModel {
    let id: UUID
    var name: String
    var state: HomeState
    var rooms: [RoomModel]
}

enum HomeState {
    case normal
    case permissionsRequired
    case noDevices
}
