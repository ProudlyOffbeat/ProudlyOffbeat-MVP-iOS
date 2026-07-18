//
//  StatisticsViewModel.swift
//  LivingStory-iOS
//
//  내 독서 요약 상태/로직 (StatisticsView 에서 분리).
//  리포지토리에서 읽은 날짜·세션을 로드해 스트릭/월간/누적/달력 데이터를 파생한다.
//

import Foundation
import Observation

@MainActor
@Observable
final class StatisticsViewModel {

    // MARK: - 파생 상태 (load()에서 리포지토리로 채움)

    private(set) var flameCount = 0                 // 연속 독서일(스트릭) — 읽은 날짜로 계산
    private(set) var monthlyCount = 0               // 이번 달 읽어준 횟수(세션 수)
    private(set) var totalReadCount = 0             // 누적 고유 책 수(중복 제외)
    private(set) var readBooks: [BookProfileModel] = []      // 누적 고유 책 목록(최근 순)
    private(set) var readDates: Set<DateComponents> = []     // 책 읽은 날짜(달력 표시용)
    private(set) var earliestMonth: Date?           // 최초 독서월(달력 과거 슬라이드 하한)

    /// 상단 "이번 달" 라벨 — 현재 월을 한국어로 표시 (yyyy년 M월). 화면 수명동안 고정.
    let monthLabel: String

    private let repository: ReadingSessionRepositoryProtocol

    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        self.monthLabel = formatter.string(from: Date())
    }

    // MARK: - Load

    /// 화면 진입 시 리포지토리에서 실제 통계를 읽어 상태에 채운다.
    /// 새 세션이 저장된 뒤 탭으로 돌아와도 최신 값이 반영되도록 onAppear마다 호출.
    func load() {
        let dates = (try? repository.fetchReadDates()) ?? []

        readDates = dates
        // 스트릭은 진실의 원천 하나(StreakCalculator, 알림 스케줄러와 공용)로 계산 — 중복 로직 금지.
        flameCount = (try? repository.fetchCurrentStreak()) ?? 0
        earliestMonth = Self.earliestMonth(from: dates)
        monthlyCount = (try? repository.fetchMonthlyBookCount()) ?? 0
        totalReadCount = (try? repository.fetchTotalBookCount()) ?? 0
        readBooks = Self.uniqueBooks(from: (try? repository.fetchAllSessions()) ?? [])
    }

    // MARK: - 순수 파생 로직 (테스트 가능)

    /// 가장 처음 책을 읽은 '월'의 1일. 달력 과거 슬라이드 하한으로 쓴다. (기록 없으면 nil)
    static func earliestMonth(from readDates: Set<DateComponents>) -> Date? {
        let cal = Calendar(identifier: .gregorian)
        let monthStarts = readDates.compactMap { comps -> Date? in
            guard let y = comps.year, let m = comps.month else { return nil }
            return cal.date(from: DateComponents(year: y, month: m, day: 1))
        }
        return monthStarts.min()
    }

    /// 세션 목록(최근 순)에서 ISBN 기준 중복을 제거한 고유 책 목록.
    static func uniqueBooks(from sessions: [ReadingSessionProfile]) -> [BookProfileModel] {
        var seen = Set<String>()
        return sessions.compactMap { session in
            let isbn = session.bookProfile.isbn
            guard !seen.contains(isbn) else { return nil }
            seen.insert(isbn)
            return session.bookProfile
        }
    }
}
