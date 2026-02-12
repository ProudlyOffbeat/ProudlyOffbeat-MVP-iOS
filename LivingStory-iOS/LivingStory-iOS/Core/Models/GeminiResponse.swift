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
}
