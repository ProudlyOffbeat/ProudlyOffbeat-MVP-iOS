//
//  ReadingSessionRepositoryTests.swift
//  LivingStory-iOSTests
//
//  ReadingSessionRepository 통합 테스트 — 인메모리 CoreData(NaruModel) 스택을 매 테스트마다 새로 띄워 격리.
//  세션에서 파생되는 통계(읽은 날짜/월간/스트릭/시간)가 실제 저장과 일치하는지 검증한다.
//

import XCTest
import CoreData
@testable import LivingStory_iOS

@MainActor
final class ReadingSessionRepositoryTests: XCTestCase {

    private var repo: ReadingSessionRepository!

    override func setUp() {
        super.setUp()
        // /dev/null 스토어 = 디스크에 안 쓰는 인메모리, 테스트 간 상태 공유 없음
        let container = NSPersistentContainer(name: "NaruModel")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        let exp = expectation(description: "load store")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
        repo = ReadingSessionRepository(context: container.viewContext)
    }

    override func tearDown() {
        repo = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSession(isbn: String, start: Date) -> ReadingSessionProfile {
        ReadingSessionProfile(
            id: UUID(),
            startTime: start,
            endTime: start.addingTimeInterval(300),
            durationSeconds: 300,
            bookProfile: BookProfileModel(
                isbn: isbn,
                bookCoverImageURL: nil,
                bookTitle: "테스트 책",
                bookAuthor: "저자",
                bookPublisher: "출판사",
                bookDescription: "설명"
            ),
            musicCategory: nil,
            lighting: .default,
            conversations: [],
            memo: nil,
            createdAt: start
        )
    }

    // MARK: - Tests

    func test_저장한세션의_읽은날짜가_정확히집계된다() throws {
        let cal = Calendar(identifier: .gregorian)
        let d1 = cal.date(from: DateComponents(year: 2026, month: 7, day: 10))!
        let d2 = cal.date(from: DateComponents(year: 2026, month: 7, day: 11))!
        try repo.saveSession(makeSession(isbn: "111", start: d1), bookISBN: "111")
        try repo.saveSession(makeSession(isbn: "111", start: d2), bookISBN: "111")

        XCTAssertEqual(try repo.fetchReadDates().count, 2)
    }

    func test_같은날_두세션이면_읽은날짜는_1개로_중복제거() throws {
        let cal = Calendar(identifier: .gregorian)
        let morning = cal.date(from: DateComponents(year: 2026, month: 7, day: 10, hour: 9))!
        let night = cal.date(from: DateComponents(year: 2026, month: 7, day: 10, hour: 21))!
        try repo.saveSession(makeSession(isbn: "111", start: morning), bookISBN: "111")
        try repo.saveSession(makeSession(isbn: "222", start: night), bookISBN: "222")

        XCTAssertEqual(try repo.fetchReadDates().count, 1)
    }

    func test_이번달세션수_집계() throws {
        let now = Date()
        try repo.saveSession(makeSession(isbn: "111", start: now), bookISBN: "111")
        try repo.saveSession(makeSession(isbn: "222", start: now), bookISBN: "222")

        XCTAssertEqual(try repo.fetchMonthlyBookCount(), 2)
    }

    func test_총독서시간_합산() throws {
        let now = Date()
        try repo.saveSession(makeSession(isbn: "111", start: now), bookISBN: "111") // 300초
        try repo.saveSession(makeSession(isbn: "222", start: now), bookISBN: "222") // 300초

        XCTAssertEqual(try repo.fetchTotalSeconds(), 600)
    }

    func test_오늘세션이있으면_오늘읽음이_참이고_스트릭은1이상() throws {
        try repo.saveSession(makeSession(isbn: "111", start: Date()), bookISBN: "111")

        XCTAssertTrue(try repo.hasReadToday())
        XCTAssertGreaterThanOrEqual(try repo.fetchCurrentStreak(), 1)
    }

    func test_세션이없으면_통계는_0() throws {
        XCTAssertEqual(try repo.fetchReadDates().count, 0)
        XCTAssertEqual(try repo.fetchMonthlyBookCount(), 0)
        XCTAssertEqual(try repo.fetchCurrentStreak(), 0)
        XCTAssertFalse(try repo.hasReadToday())
    }
}
