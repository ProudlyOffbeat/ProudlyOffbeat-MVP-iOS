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

    enum Reading {
        static let settingTitle = "환경 세팅중..."
        static let settingSubtitle = "몇 분 소요될 수 있습니다."
        static let settingDoneTitle = "책 분위기에 맞게 환경이 세팅 됐어요!"
        static let settingDoneSubtitle = "이제 책을 더 재밌게 읽으세요!"
        static let stopSettingAlert = "환경 세팅을 전체 중단할까요?"
        static let stopReadingAlert = "책 읽기를 그만할까요?"
        static let close = "닫기"
        static let stop = "중단"
        static let stopSettingButton = "환경 세팅 중지"
        static let stopReadingButton = "그만 읽기"
        static let stopReadingAlertMessage = "중단시, 세팅된 환경이 중단될 거에요."
        static let conversationPrompt = "책에 대해 아이와 대화를 나눠보세요."
        static let restartScan = "다른 책 스캔"
        static let setupButton = "책 환경 세팅하기"
        static let resultTitle = "읽은 책"
        static let homeButton = "홈으로"
        static func todayBookCount(_ count: Int) -> String { "오늘 아이에게\n책을 \(count)번 읽어줬어요!" }
    }

    enum Book {
        static let title = "책 읽기"
        static let startButton = "책 읽기 시작하기"

        static let tagUsage = "사용법"
        static let tag01 = "01"
        static let tag02 = "02"
        static let tag03 = "03"
        static let tag04 = "04"

        static let titleUsage = "책에 맞는 분위기를 만들어\n아이에게 책을 읽어주세요!"
        static let title01 = "읽을 책의 바코드를 스캔해요"
        static let title02 = "스캔한 책의 분위기에 맞게\n조명과 스피커가 세팅돼요"
        static let title03 = "멋진 분위기에서\n아이에게 책을 읽어줘요"
        static let title04 = "다 읽으면 책에 대해\n아이와 나눌만한 대화를 제안해줘요"

        static let imageUsage = "UsingIntro"
        static let image01 = "UsingIntro1"
        static let image02 = "UsingIntro2"
        static let image03 = "UsingIntro3"
        static let image04 = "UsingIntro4"
    }

    enum Scanner {
        static let title = "바코드 스캔"
        static let recognizing = "바코드 인식중"
        static let success = "인식 완료!"
        static let failed = "인식 실패"
        static let retry = "다시 시도"
        static let guideTitle = "책 뒷면의 바코드 스캔"
        static let guideSubtitle = "정확한 책의 정보를 가져오기 위해, 읽으실 책의 바코드를 스캔해주세요. 바코드는 주로 뒷면에 위치해 있습니다."
        static let cameraPermissionTitle = "카메라 권한 필요"
        static let cameraPermissionMessage = "바코드를 스캔하려면 카메라 접근 권한이 필요합니다."
        static let cancel = "취소"
        static let goToSettings = "설정으로 이동"
    }

    enum My {
        static let title = "마이"
        static let monthlyBookCount = "이번 달 읽어준 횟수"
        static let totalBookCount = "총 읽은 책 수"
        static let totalReadingTime = "총 읽은 시간"
        static let bookUnit = "권"
        static let readingUnit = "번"
        static let hourUnit = "시간"
        static let minuteUnit = "분"
        static let secondUnit = "초"
    }

    enum Calendar {
        static let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    }

    enum Onboarding {
        static let coachMark1 = "책 읽기 시작하기를 통해 스캔한 책에 맞는 분위기로 조명과 스피커를 세팅할 수 있어요"
        static let coachMark2 = "책 읽기에 사용할 장치를 설정할 수 있어요"
        static let coachMark3 = "지금까지 내가 책을 읽은 시간과 권 수를 확인할 수 있어요"
        static let next = "다음"
        static let start = "시작하기"
    }
}
