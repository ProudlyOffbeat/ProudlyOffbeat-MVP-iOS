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

    /// 첫 실행 환경 세팅(집/조명/스피커/나이/시간) 완료 여부 — 코치마크처럼 1회만 노출
    @UserDefault(key: "hasCompletedInitialSetup", defaultValue: false)
    static var hasCompletedInitialSetup: Bool
}
