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
}
