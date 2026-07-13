//
//  SetupStep.swift
//  LivingStory-iOS
//
//  첫 실행 세팅 플로우의 단계 정의.
//  rawValue 순서 = 진행 순서. 화면 텍스트/아이콘/CTA/뒤로가기 정책을 단계가 스스로 안다.
//  (문자열은 StringLiterals.OnboardingSetting, 아이콘은 SymbolLiterals 참조)
//

import Foundation

enum SetupStep: Int, CaseIterable, Equatable {
    case home      // 어디에서 사용 (집 선택)
    case light     // 조명 선택
    case speaker   // 스피커 선택
    case age       // 아이 나이
    case time      // 읽어줄 시간

    var title: String {
        switch self {
        case .home:    StringLiterals.OnboardingSetting.homeTitle
        case .light:   StringLiterals.OnboardingSetting.lightTitle
        case .speaker: StringLiterals.OnboardingSetting.speakerTitle
        case .age:     StringLiterals.OnboardingSetting.ageTitle
        case .time:    StringLiterals.OnboardingSetting.timeTitle
        }
    }

    var subtitle: String {
        switch self {
        case .home:    StringLiterals.OnboardingSetting.homeSubtitle
        case .light:   StringLiterals.OnboardingSetting.lightSubtitle
        case .speaker: StringLiterals.OnboardingSetting.speakerSubtitle
        case .age:     StringLiterals.OnboardingSetting.ageSubtitle
        case .time:    StringLiterals.OnboardingSetting.timeSubtitle
        }
    }

    var icon: SymbolLiterals {
        switch self {
        case .home:    .home          // house.fill (기존 재사용)
        case .light:   .lightbulb     // lightbulb.fill (기존 재사용)
        case .speaker: .setupSpeaker
        case .age:     .setupAge
        case .time:    .alarm
        }
    }

    var ctaTitle: String {
        self == .time ? StringLiterals.OnboardingSetting.done : StringLiterals.OnboardingSetting.next
    }

    var showsBackButton: Bool { self != .home }
    var isSkippable: Bool { self == .time }
}
