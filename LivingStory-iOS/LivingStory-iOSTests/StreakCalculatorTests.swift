//
//  StreakCalculatorTests.swift
//  LivingStory-iOSTests
//
//  스트릭(연속 독서일) 순수 계산 로직 유닛 테스트.
//  저장소·시계에 의존하지 않도록 today/calendar를 주입해 결정적으로 검증한다.
//

import XCTest
@testable import LivingStory_iOS

final class StreakCalculatorTests: XCTestCase {

    private let cal = Calendar(identifier: .gregorian)
    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    // MARK: - currentStreak

    func test_currentStreak_빈집합이면_0() {
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: [], today: day(2026, 7, 18), calendar: cal), 0)
    }

    func test_currentStreak_오늘하루만_1() {
        let today = day(2026, 7, 18)
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: [today], today: today, calendar: cal), 1)
    }

    func test_currentStreak_오늘까지_연속3일() {
        let days: Set<Date> = [day(2026, 7, 16), day(2026, 7, 17), day(2026, 7, 18)]
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: days, today: day(2026, 7, 18), calendar: cal), 3)
    }

    func test_currentStreak_오늘미독서_어제까지연속이면_유지() {
        // 듀오링고식 그레이스: 오늘 아직 안 읽었어도 어제 읽었으면 유지
        let days: Set<Date> = [day(2026, 7, 16), day(2026, 7, 17)]
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: days, today: day(2026, 7, 18), calendar: cal), 2)
    }

    func test_currentStreak_어제도그제도미독서면_0() {
        let days: Set<Date> = [day(2026, 7, 15), day(2026, 7, 16)]
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: days, today: day(2026, 7, 18), calendar: cal), 0)
    }

    func test_currentStreak_불연속이면_최근연속구간만_카운트() {
        let days: Set<Date> = [day(2026, 7, 10), day(2026, 7, 17), day(2026, 7, 18)]
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: days, today: day(2026, 7, 18), calendar: cal), 2)
    }

    // MARK: - longestStreak

    func test_longestStreak_최장연속구간() {
        let days: Set<Date> = [day(2026, 7, 1), day(2026, 7, 2), day(2026, 7, 3),
                               day(2026, 7, 10), day(2026, 7, 11)]
        XCTAssertEqual(StreakCalculator.longestStreak(readDays: days, calendar: cal), 3)
    }

    func test_longestStreak_빈집합이면_0() {
        XCTAssertEqual(StreakCalculator.longestStreak(readDays: [], calendar: cal), 0)
    }

    // MARK: - normalizedDays

    func test_normalizedDays_서로다른날짜3개_3개로변환() {
        let comps: Set<DateComponents> = [
            DateComponents(year: 2026, month: 7, day: 16),
            DateComponents(year: 2026, month: 7, day: 17),
            DateComponents(year: 2026, month: 7, day: 18)
        ]
        let days = StreakCalculator.normalizedDays(from: comps, calendar: cal)
        XCTAssertEqual(days.count, 3)
        // startOfDay로 정규화되어 currentStreak과 합성 가능
        XCTAssertEqual(StreakCalculator.currentStreak(readDays: days, today: day(2026, 7, 18), calendar: cal), 3)
    }
}
