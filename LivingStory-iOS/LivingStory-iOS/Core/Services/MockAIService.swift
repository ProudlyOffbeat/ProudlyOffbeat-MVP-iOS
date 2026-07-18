//
//  MockAIService.swift
//  LivingStory-iOS
//
//  AIService의 테스트·프리뷰용 구현체.
//  네트워크를 타지 않고 고정값을 돌려주거나, 지정한 오류를 던진다.
//  - SwiftUI 프리뷰: 실제 API 호출 없이 화면 구성
//  - 유닛 테스트: 성공·실패 경로를 결정적으로 재현
//

import Foundation

#if DEBUG
struct MockAIService: AIService {

    /// 던질 오류. nil이면 성공 응답을 돌려준다.
    let error: AIServiceError?
    let environment: AIEnvironment
    let questions: [ConversationProfile]

    /// 기본 질문 세트 — 기본 액터 격리를 타지 않도록 nonisolated로 둔다
    nonisolated static let defaultQuestions: [ConversationProfile] = [
        ConversationProfile(id: UUID(), question: "주인공은 왜 그런 선택을 했을까?", effect: "인물의 마음을 헤아려요"),
        ConversationProfile(id: UUID(), question: "너라면 어떻게 했을 것 같아?", effect: "자기 생각을 표현해요"),
        ConversationProfile(id: UUID(), question: "가장 기억에 남는 장면은 뭐야?", effect: "이야기를 정리해요")
    ]

    nonisolated init(
        error: AIServiceError? = nil,
        environment: AIEnvironment = .mock,
        questions: [ConversationProfile] = MockAIService.defaultQuestions
    ) {
        self.error = error
        self.environment = environment
        self.questions = questions
    }

    func generateQuestions(for book: BookProfileModel, age: Int) async throws -> [ConversationProfile] {
        if let error { throw error }
        return questions
    }

    func generateEnvironment(for book: BookProfileModel) async throws -> AIEnvironment {
        if let error { throw error }
        return environment
    }
}

extension AIEnvironment {
    /// 기본 액터 격리(MainActor)에 묶이면 테스트에서 못 읽으므로 nonisolated로 노출
    nonisolated static let mock = AIEnvironment(
        lighting: LightingConfig(hue: 40, saturation: 70, brightness: 60),
        musicCategory: .warm
    )
}

#endif
