//
//  ReadingSessionRepositoryProtocol.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation

protocol ReadingSessionRepositoryProtocol {
    // MARK: - CRUD
    func saveSession(_ session: ReadingSessionProfile, bookISBN: String) throws
    func fetchAllSessions() throws -> [ReadingSessionProfile]
    func findSession(by id: UUID) throws -> ReadingSessionProfile?
    func deleteSession(by id: UUID) throws
    
    // MARK: - 통계 쿼리
    func fetchTodaySessions() throws -> [ReadingSessionProfile]
    func fetchMonthlyBookCount() throws -> Int
    func fetchTotalBookCount() throws -> Int
    func fetchTotalSeconds() throws -> Int
    func fetchReadDates() throws -> Set<DateComponents>

    // MARK: - 스트릭 (기본구현 제공 — 기존 세션 데이터에서 파생)
    func fetchCurrentStreak() throws -> Int
    func hasReadToday() throws -> Bool
}

// 세션 데이터에서 파생 — 별도 저장 안 함(진실의 원천은 CoreData 세션). 기존 mock도 자동 충족.
extension ReadingSessionRepositoryProtocol {
    func fetchCurrentStreak() throws -> Int {
        let days = StreakCalculator.normalizedDays(from: try fetchReadDates())
        return StreakCalculator.currentStreak(readDays: days, today: Date())
    }

    func hasReadToday() throws -> Bool {
        try !fetchTodaySessions().isEmpty
    }
}
