//
//  ReadingNotificationScheduler.swift
//  LivingStory-iOS
//
//  독서 알림 스케줄러 (로컬 노티).
//   ① 매일 정시 리마인더  ② 정시 10분 후 재알림  ③ 22시 스트릭 깨짐 경고
//  시간 소스 = UserData.notificationTime / notificationEnabled (단일 소스).
//  스트릭/오늘 읽음 여부는 CoreData 세션에서 파생(ReadingSessionRepository).
//

import Foundation
import UserNotifications

@MainActor
final class ReadingNotificationScheduler {

    static let shared = ReadingNotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let sessionRepository: ReadingSessionRepositoryProtocol

    private enum ID {
        static let reminder = "reading.reminder"        // 매일 정시 (반복)
        static let followUp = "reading.followUp"         // 정시 +10분 (오늘 1회)
        static let streakWarning = "reading.streakWarning" // 22시 (오늘 1회)
    }

    init() {
        self.sessionRepository = ReadingSessionRepository()
    }

    /// 테스트 주입용
    init(sessionRepository: ReadingSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    // MARK: - 권한

    /// 권한 요청 (온보딩 시간설정 직후 호출 권장). 반환: 허용 여부.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        await refreshSchedule()
        return granted
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - 스케줄

    /// 현재 상태(설정시간·오늘 읽음·스트릭) 기준으로 전체 재스케줄. 앱 포그라운드·설정변경·독서완료 시 호출.
    func refreshSchedule() async {
        center.removePendingNotificationRequests(withIdentifiers: [ID.reminder, ID.followUp, ID.streakWarning])

        guard UserData.notificationEnabled else { return }
        guard await authorizationStatus() == .authorized else { return }

        let cal = Calendar.current
        let timeComps = cal.dateComponents([.hour, .minute], from: UserData.notificationTime)
        let hour = timeComps.hour ?? 21
        let minute = timeComps.minute ?? 30

        // ① 매일 정시 리마인더 (반복)
        var daily = DateComponents()
        daily.hour = hour
        daily.minute = minute
        add(id: ID.reminder,
            title: "지금 책 읽을 시간이에요! 📖",
            body: "오늘의 동화책, 아이와 함께 읽어볼까요?",
            trigger: UNCalendarNotificationTrigger(dateMatching: daily, repeats: true))

        // ② 정시 10분 후 재알림 (반복 — 앱 안 켜도 매일 발송. 문구가 중립적이라 읽은 날 와도 어색하지 않음)
        let followTotal = hour * 60 + minute + 10
        var follow = DateComponents()
        follow.hour = (followTotal / 60) % 24
        follow.minute = followTotal % 60
        add(id: ID.followUp,
            title: "오늘의 동화책 시간 🌙",
            body: "아이의 상상력을 키우는 습관 5분이면 충분해요. 함께 읽어볼까요?",
            trigger: UNCalendarNotificationTrigger(dateMatching: follow, repeats: true))
        // (22시 스트릭 경고는 제거 — 앱 안 켜면 스트릭 상태를 몰라 신뢰성이 떨어져서 배제)
    }

    /// 세션 완료 직후 — 오늘의 재알림/경고를 취소하고 재스케줄(오늘 읽음 반영).
    func onDidRead() async {
        await refreshSchedule()
    }

    // MARK: - Private

    private func add(id: String, title: String, body: String, trigger: UNNotificationTrigger) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func oneShot(_ date: Date, _ cal: Calendar) -> UNCalendarNotificationTrigger {
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
    }
}
