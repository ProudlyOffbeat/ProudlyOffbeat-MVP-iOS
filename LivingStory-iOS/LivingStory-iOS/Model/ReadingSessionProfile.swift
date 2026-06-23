//
//  ReadingSessionProfile.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation

struct ReadingSessionProfile: Sendable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let durationSeconds: Int
    let bookProfile: BookProfileModel
    let musicCategory: MusicCategory?
    let lighting: LightingConfig
    let conversations: [ConversationProfile]
    let memo: String?
    let createdAt: Date
}

// MARK: - Mock

extension ReadingSessionProfile {
    static let mock = ReadingSessionProfile(
        id: UUID(),
        startTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date())!,
        endTime: Date(),
        durationSeconds: 1800,
        bookProfile: .mock,
        musicCategory: .warm,
        lighting: LightingConfig(hue: 40, saturation: 60, brightness: 80),
        conversations: ConversationProfile.mockList,
        memo: nil,
        createdAt: Date()
    )

    static let mockList: [ReadingSessionProfile] = [
        .mock,
        ReadingSessionProfile(
            id: UUID(),
            startTime: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            endTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            durationSeconds: 3600,
            bookProfile: .mockISBN,
            musicCategory: .peaceful,
            lighting: LightingConfig(hue: 200, saturation: 40, brightness: 70),
            conversations: [ConversationProfile.mock],
            memo: "재미있었다!",
            createdAt: Date()
        )
    ]
}
