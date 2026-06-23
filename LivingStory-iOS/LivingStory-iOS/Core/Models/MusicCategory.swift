//
//  MusicCategory.swift
//  LivingStory-iOS
//

import Foundation

/// 나루 음악 시스템 — 5개 대분류 아래 12개 무드 카테고리.
/// rawValue는 Gemini가 정확히 받아쓰기 쉽도록 영문 단일 토큰으로 둔다(JSON 디코딩 안정).
enum MusicCategory: String, Codable, CaseIterable, Sendable {
    // 사랑/안정
    case warm = "Warm"          // 무조건적 사랑과 포근한 안도감
    case cozy = "Cozy"          // 작고 아늑한 공간의 편안함
    // 자연/고요
    case peaceful = "Peaceful"  // 고요하고 잔잔한 안정감
    case airy = "Airy"          // 맑고 가볍게 통풍되는 청량감
    case dreamy = "Dreamy"      // 몽환적이고 경계가 흐린 상상 속 고요함
    // 감정/공감
    case healing = "Healing"    // 감정의 상처가 천천히 아무는 위로
    case lyrical = "Lyrical"    // 서정적이고 감성적인 흐름
    // 상상/모험
    case curious = "Curious"        // 탐색하고 싶은 호기심과 설렘
    case fairytale = "Fairytale"    // 밝고 따뜻한 동화 속 세계
    case mysterious = "Mysterious"  // 어둡지 않지만 신비롭고 미지의 느낌
    // 유머/에너지
    case playful = "Playful"    // 가볍고 경쾌한 즐거움
    case quirky = "Quirky"      // 예측 불가하고 해학적인 유머감

    /// 번들에 포함된 오디오 파일명(확장자 제외). 공백·특수문자 없는 소문자 토큰으로 통일.
    var audioFileName: String {
        switch self {
        case .warm: return "warm"
        case .cozy: return "cozy"
        case .peaceful: return "peaceful"
        case .airy: return "airy"
        case .dreamy: return "dreamy"
        case .healing: return "healing"
        case .lyrical: return "lyrical"
        case .curious: return "curious"
        case .fairytale: return "fairytale"
        case .mysterious: return "mysterious"
        case .playful: return "playful"
        case .quirky: return "quirky"
        }
    }

    /// 프롬프트에 넣을 카테고리 안내. 각 토큰에 한글 무드 설명을 붙여 Gemini가 정확히 매핑하게 한다.
    nonisolated static let promptList = """
    - Warm: 무조건적 사랑과 포근한 안도감
    - Cozy: 작고 아늑한 공간의 편안함
    - Peaceful: 고요하고 잔잔한 안정감
    - Airy: 맑고 가볍게 통풍되는 청량감
    - Dreamy: 몽환적이고 경계가 흐린 상상 속 고요함
    - Healing: 감정의 상처가 천천히 아무는 위로
    - Lyrical: 서정적이고 감성적인 흐름
    - Curious: 탐색하고 싶은 호기심과 설렘
    - Fairytale: 밝고 따뜻한 동화 속 세계
    - Mysterious: 어둡지 않지만 신비롭고 미지의 느낌
    - Playful: 가볍고 경쾌한 즐거움
    - Quirky: 예측 불가하고 해학적인 유머감
    """
}
