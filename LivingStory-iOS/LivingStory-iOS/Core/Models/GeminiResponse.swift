//
//  GeminiResponse.swift
//  LivingStory-iOS
//

import Foundation

// MARK: - Gemini API 응답 구조

/// Gemini가 생성한 독서 환경 설정
struct ReadingEnvironment: Codable {
    let musicCategory: MusicCategory
    let lighting: LightingConfig
    let conversations: [ConversationDTO]
}

/// Gemini 응답용 대화 주제 DTO (Codable)
struct ConversationDTO: Codable {
    let question: String
    let effect: String
}

// MARK: - 도메인 모델 변환

extension ConversationDTO {
    func toDomain() -> Conversation {
        Conversation(question: question, effect: effect)
    }
}

extension ReadingEnvironment {
    func toDomainConversations() -> [Conversation] {
        conversations.map { $0.toDomain() }
    }

    static let mock = ReadingEnvironment(
        musicCategory: .fantasy,
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
