//
//  ConversationEntity+Extensions.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation
import CoreData

// MARK: - ConversationEntity → ConversationProfile 변환 (읽기)

extension ConversationEntity {

    func toProfile() -> ConversationProfile {
        ConversationProfile(
            id: id ?? UUID(),
            question: question ?? "",
            effect: effect ?? ""
        )
    }
}
