//
//  ReadingSessionRepository.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//


import Foundation
import CoreData

@MainActor
final class ReadingSessionRepository: ReadingSessionRepositoryProtocol {
    
    private let context: NSManagedObjectContext

    init() {
        self.context = PersistenceController.shared.context
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - 저장
    
    func saveSession(_ session: ReadingSessionProfile, bookISBN: String) throws {
        let entity = ReadingSessionEntity(context: context)
        entity.id = session.id
        entity.startTime = session.startTime
        entity.endTime = session.endTime
        entity.duration = Double(session.durationSeconds)
        entity.musicCategory = session.musicCategory?.rawValue
        entity.lightingHue = Int16(session.lighting.hue)
        entity.lightingSaturation = Int16(session.lighting.saturation)
        entity.lightingBrightness = Int16(session.lighting.brightness)
        entity.memo = session.memo
        entity.createdAt = Date()
        
        // Book 연결
        let bookRequest = BookEntity.fetchRequest()
        bookRequest.predicate = NSPredicate(format: "isbn == %@", bookISBN)
        bookRequest.fetchLimit = 1
        entity.book = try context.fetch(bookRequest).first
        
        // Conversation 저장
        for conversation in session.conversations {
            let conversationEntity = ConversationEntity(context: context)
            conversationEntity.id = conversation.id
            conversationEntity.question = conversation.question
            conversationEntity.effect = conversation.effect
            conversationEntity.createdAt = Date()
            conversationEntity.session = entity
        }
        
        try context.save()
    }
    
    // MARK: - 전체 조회
    
    func fetchAllSessions() throws -> [ReadingSessionProfile] {
        let request = ReadingSessionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        return try context.fetch(request).map { $0.toProfile() }
    }
    
    // MARK: - 1건 조회
    
    func findSession(by id: UUID) throws -> ReadingSessionProfile? {
        try findEntity(by: id)?.toProfile()
    }
    
    // MARK: - 삭제
    
    func deleteSession(by id: UUID) throws {
        guard let entity = try findEntity(by: id) else { return }
        context.delete(entity)
        try context.save()
    }
    
    // MARK: - 통계 쿼리
    
    func fetchTodaySessions() throws -> [ReadingSessionProfile] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = ReadingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "startTime >= %@ AND startTime < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        return try context.fetch(request).map { $0.toProfile() }
    }

    func fetchMonthlyBookCount() throws -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        let request = ReadingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "startTime >= %@ AND startTime < %@",
            startOfMonth as NSDate,
            endOfMonth as NSDate
        )
        let sessions = try context.fetch(request)
        // TODO: 고유 책 수가 아닌 읽어준 횟수(세션 수) 기준으로 변경
        // let uniqueISBNs = Set(sessions.compactMap { $0.book?.isbn })
        // return uniqueISBNs.count
        return sessions.count
    }

    func fetchTotalBookCount() throws -> Int {
        let request = ReadingSessionEntity.fetchRequest()
        let sessions = try context.fetch(request)
        let uniqueISBNs = Set(sessions.compactMap { $0.book?.isbn })
        return uniqueISBNs.count
    }
    
    func fetchTotalSeconds() throws -> Int {
        let request = ReadingSessionEntity.fetchRequest()
        let sessions = try context.fetch(request)
        return sessions.reduce(0) { $0 + Int($1.duration) }
    }
    
    func fetchReadDates() throws -> Set<DateComponents> {
        let request = ReadingSessionEntity.fetchRequest()
        let sessions = try context.fetch(request)
        let calendar = Calendar.current
        let components = sessions.compactMap { session -> DateComponents? in
            guard let startTime = session.startTime else { return nil }
            return DateComponents(
                year: calendar.component(.year, from: startTime),
                month: calendar.component(.month, from: startTime),
                day: calendar.component(.day, from: startTime)
            )
        }
        return Set(components)
    }
    
    // MARK: - Private
    
    private func findEntity(by id: UUID) throws -> ReadingSessionEntity? {
        let request = ReadingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
