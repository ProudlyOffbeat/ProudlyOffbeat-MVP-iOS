//
//  StreakCalculator.swift
//  LivingStory-iOS
//
//  읽은 날짜 집합에서 스트릭(연속일)을 계산하는 순수 로직.
//  저장소·UI와 무관 → 유닛테스트 가능, 중복 제거(마이·책·결과 화면 공용).
//

import Foundation

enum StreakCalculator {

    /// 현재 스트릭(연속일). 듀오링고식: 오늘 안 읽었어도 어제 읽었으면 유지(오늘 자정 전까지),
    /// 어제도 안 읽었으면 0.
    static func currentStreak(readDays: Set<Date>, today: Date, calendar: Calendar = .current) -> Int {
        let startToday = calendar.startOfDay(for: today)

        // 카운트 시작점: 오늘 읽었으면 오늘, 아니면 어제(어제 읽었으면 아직 유지)
        var day: Date
        if readDays.contains(startToday) {
            day = startToday
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: startToday),
                  readDays.contains(yesterday) {
            day = yesterday
        } else {
            return 0
        }

        var streak = 0
        while readDays.contains(day) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    /// 역대 최장 스트릭 (통계용)
    static func longestStreak(readDays: Set<Date>, calendar: Calendar = .current) -> Int {
        guard !readDays.isEmpty else { return 0 }
        let sorted = readDays.sorted()
        var longest = 1
        var current = 1
        for i in 1..<sorted.count {
            if let next = calendar.date(byAdding: .day, value: 1, to: sorted[i - 1]),
               calendar.isDate(next, inSameDayAs: sorted[i]) {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
        }
        return longest
    }

    /// DateComponents(년/월/일) 집합 → startOfDay Date 집합
    static func normalizedDays(from components: Set<DateComponents>, calendar: Calendar = .current) -> Set<Date> {
        Set(components.compactMap { calendar.date(from: $0).map { calendar.startOfDay(for: $0) } })
    }
}
