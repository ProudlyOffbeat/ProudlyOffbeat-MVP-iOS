//
//  HomeKitAuthState.swift
//  LivingStory-iOS
//
//  HomeKit 권한 상태를 의미 단위로 표현.
//  HMHomeManagerAuthorizationStatus(OptionSet)를 다루기 쉬운 enum으로 변환한다.
//

import HomeKit

enum HomeKitAuthState: Equatable {
    case undetermined   // 아직 사용자가 선택하지 않음
    case authorized     // 허용됨
    case denied         // 선택했으나 미허용 (거부)
    case restricted     // 제한됨 (자녀 보호 등)

    init(_ status: HMHomeManagerAuthorizationStatus) {
        if status.contains(.restricted) {
            self = .restricted
        } else if status.contains(.authorized) {
            self = .authorized
        } else if status.contains(.determined) {
            self = .denied
        } else {
            self = .undetermined
        }
    }

    /// 세팅 플로우 진입 가능 여부
    var canEnterSetup: Bool { self == .authorized }
}
