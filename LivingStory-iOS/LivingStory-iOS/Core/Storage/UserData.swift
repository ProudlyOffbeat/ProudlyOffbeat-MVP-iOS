//
//  UserData.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//

import Foundation

struct UserData {
    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    static var hasCompletedOnboarding: Bool
}
