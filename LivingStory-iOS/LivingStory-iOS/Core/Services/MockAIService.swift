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

    init(
        error: AIServiceError? = nil,
        environment: AIEnvironment = .mock,
        questions: [ConversationProfile] = ConversationProfile.mockList
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
    static let mock = AIEnvironment(
        lighting: LightingConfig(hue: 40, saturation: 70, brightness: 60),
        musicCategory: .warm
    )
}

#endif
