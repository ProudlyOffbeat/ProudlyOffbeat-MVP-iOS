//
//  ReadingSessionStore.swift
//  LivingStory-iOS
//
//  인메모리 저장소 (추후 CoreData Repository로 교체)
//

import Foundation

@MainActor
@Observable
final class ReadingSessionStore {

    static let shared = ReadingSessionStore()

    private(set) var sessions: [ReadingSession] = ReadingSession.mockList

    private init() {}

    // MARK: - 저장

    func addSession(_ session: ReadingSession) {
        sessions.append(session)
    }

    // MARK: - 조회

    /// 오늘 읽은 세션 목록
    var todaySessions: [ReadingSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startTime) }
    }

    /// 오늘 읽은 책 수
    var todayBookCount: Int {
        todaySessions.count
    }

    /// 이번 달 읽은 책 수
    var monthlyBookCount: Int {
        let now = Date()
        let calendar = Calendar.current
        return sessions.filter {
            calendar.component(.year, from: $0.startTime) == calendar.component(.year, from: now) &&
            calendar.component(.month, from: $0.startTime) == calendar.component(.month, from: now)
        }.count
    }

    /// 총 읽은 책 수
    var totalBookCount: Int {
        sessions.count
    }

    /// 총 읽은 시간 (분)
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.duration }
    }

    /// 총 읽은 시간 (표시용 문자열)
    var totalTimeString: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }

    /// 읽은 날짜 (캘린더용)
    var readDateComponents: Set<DateComponents> {
        let calendar = Calendar.current
        let components = sessions.map {
            calendar.dateComponents([.year, .month, .day], from: $0.startTime)
        }
        return Set(components)
    }
}
