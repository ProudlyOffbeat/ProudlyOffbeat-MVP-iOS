//
//  ConversationProfile.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation

struct ConversationProfile {
    let id: UUID
    let question: String
    let effect: String
}

// MARK: - Mock

extension ConversationProfile {
    static let mock = ConversationProfile(
        id: UUID(),
        question: "이 책에서 가장 기억에 남는 장면은 뭐야?",
        effect: "독해력과 감정 표현 능력을 키워줍니다."
    )

    static let mockList: [ConversationProfile] = [
        .mock,
        ConversationProfile(
            id: UUID(),
            question: "주인공은 왜 그런 선택을 했을까?",
            effect: "비판적 사고력과 공감 능력을 발달시킵니다."
        ),
        ConversationProfile(
            id: UUID(),
            question: "만약 네가 주인공이라면 어떻게 했을까?",
            effect: "창의적 사고와 자기 표현 능력을 향상시킵니다."
        )
    ]
}
