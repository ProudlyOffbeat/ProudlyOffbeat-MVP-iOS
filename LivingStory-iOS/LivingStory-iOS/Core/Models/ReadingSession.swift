//
//  ReadingSession.swift
//  LivingStory-iOS
//
//  임시 도메인 모델 (추후 CoreData Entity로 교체)
//

import Foundation

struct ReadingSession {
    let id: UUID
    let startTime: Date
    let endTime: Date
    /// 독서 시간 (분 단위)
    let duration: Int
    let book: BookRecord
    let createdAt: Date

    init(startTime: Date, endTime: Date, book: BookRecord) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = Int(endTime.timeIntervalSince(startTime) / 60)
        self.book = book
        self.createdAt = Date()
    }
}

// MARK: - Mock

extension ReadingSession {
    static let mock = ReadingSession(
        startTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date())!,
        endTime: Date(),
        book: .mock
    )

    static let mockList: [ReadingSession] = [
        ReadingSession(
            startTime: Calendar.current.date(byAdding: .minute, value: -45, to: Date())!,
            endTime: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!,
            book: .mock
        ),
        ReadingSession(
            startTime: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            endTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            book: .mock
        ),
        ReadingSession(
            startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)!,
            endTime: Calendar.current.date(bySettingHour: 10, minute: 25, second: 0, of: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)!,
            book: .mock
        ),
    ]
}
