//
//  GeminiResponse.swift
//  LivingStory-iOS
//

import Foundation

// MARK: - Gemini API 응답 구조

/// Gemini가 생성한 독서 환경 설정
struct ReadingEnvironment: Codable, Sendable {
    let musicCategory: MusicCategory
    let lighting: LightingConfig
    let conversations: [ConversationDTO]
}

/// Gemini 응답용 대화 주제 DTO (Codable)
struct ConversationDTO: Codable, Sendable {
    let question: String
    let effect: String
}

/// 2-호출 구조의 호출 B(조명·음악) 응답.
/// 질문(호출 A)과 분리되어 그라운딩 OFF + JSON 강제로 안전하게 디코딩된다.
struct LightingMusicResult: Codable, Sendable {
    let lighting: LightingConfig
    let musicCategory: MusicCategory
}

// MARK: - 도메인 모델 변환

extension ConversationDTO {
    func toProfile() -> ConversationProfile {
        ConversationProfile(id: UUID(), question: question, effect: effect)
    }
}

extension ReadingEnvironment {
    func toConversationProfiles() -> [ConversationProfile] {
        conversations.map { $0.toProfile() }
    }

    static let mock = ReadingEnvironment(
        musicCategory: .dreamy,
        lighting: LightingConfig(hue: 280, saturation: 50, brightness: 65),
        conversations: [
            ConversationDTO(
                question: "괴물이 냉장고를 왜 먹었을까? 괴물의 마음이 어땠을 것 같아?",
                effect: "타인의 입장에서 생각하는 공감 능력을 길러줘요"
            ),
            ConversationDTO(
                question: "냉장고가 없으면 우리 집은 어떻게 될까? 어떤 게 불편할까?",
                effect: "일상 속 사물의 가치를 인식하게 해줘요"
            ),
            ConversationDTO(
                question: "냉장고 없이도 맛있는 음식을 먹으려면 어떻게 하면 좋을까?",
                effect: "문제 해결력과 창의적 사고를 도와줘요"
            ),
        ]
    )
}
