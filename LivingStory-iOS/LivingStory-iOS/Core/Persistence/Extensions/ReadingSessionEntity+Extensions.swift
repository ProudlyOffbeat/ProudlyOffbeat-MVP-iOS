//
//  ReadingSessionEntity+Extensions.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation
import CoreData

// MARK: - ReadingSessionEntity → ReadingSessionProfile 변환 (읽기)

extension ReadingSessionEntity {

    func toProfile() -> ReadingSessionProfile {
        ReadingSessionProfile(
            id: id ?? UUID(),
            startTime: startTime ?? Date(),
            endTime: endTime,
            durationMinutes: Int(duration / 60),
            bookProfile: book?.toProfile() ?? BookProfileModel.mock,
            musicCategory: musicCategory.flatMap { MusicCategory(rawValue: $0) },
            lighting: LightingConfig(
                hue: Int(lightingHue),
                saturation: Int(lightingSaturation),
                brightness: Int(lightingBrightness)
            ),
            conversations: conversationProfiles,
            memo: memo,
            createdAt: createdAt ?? Date()
        )
    }

    private var conversationProfiles: [ConversationProfile] {
        guard let set = conversations as? Set<ConversationEntity> else { return [] }
        return set.map { $0.toProfile() }
    }
}
