//
//  StringLiterals.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/3/26.
//
import Foundation

enum StringLiterals {

    enum TabBar {
        static let home = "환경 세팅"
        static let book = "책 읽기"
        static let my = "마이"
    }

    enum Home {
        static let menuTitle = "모든 집 리스트"
        static let deviceOff = "꺼짐"

        // 빈 상태 - 권한 필요
        static let permissionTitle = "홈 앱 권한 허용 필요"
        static let permissionSubtitle = "나루가 홈 앱에 접근할 수 있도록\n권한을 허용해주세요"
        static let permissionButton = "설정으로 이동"

        // 빈 상태 - 기기 없음
        static let noDevicesTitle = "홈 앱에 등록된 기기가 없어요"
        static let noDevicesSubtitle = "홈 앱에서 기기를 등록해주세요"
        static let noDevicesButton = "홈 앱 열기"
    }
}
