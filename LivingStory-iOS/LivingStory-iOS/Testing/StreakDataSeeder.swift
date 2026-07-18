//
//  StreakDataSeeder.swift
//  LivingStory-iOS
//
//  -SeedStreakData 실행 시, 2026-07-03 ~ 오늘까지 "매일 다른 책 1권"의 독서 세션을 시드한다.
//  기존 세션·책을 지우고 새로 채워 결정적인 상태를 만든다. (DEBUG 전용)
//

#if DEBUG
import CoreData

enum StreakDataSeeder {

    @MainActor
    static func seedIfNeeded() {
        guard LaunchArguments.seedStreakData else { return }

        let context = PersistenceController.shared.context
        wipe(["ReadingSessionEntity", "ConversationEntity", "BookEntity"], in: context)

        let cal = Calendar(identifier: .gregorian)
        let start = cal.date(from: DateComponents(year: 2026, month: 7, day: 3))!
        let today = cal.startOfDay(for: Date())
        let titles = ["구름빵", "달님 안녕", "괴물들이 사는 나라", "무지개 물고기",
                      "돼지책", "알사탕", "코끼리 아저씨", "누가 내 머리에 똥 쌌어?",
                      "지각대장 존", "손 큰 할머니의 만두 만들기"]

        var day = start
        var index = 0
        while day <= today {
            let readAt = cal.date(byAdding: .hour, value: 20, to: day) ?? day   // 그날 저녁 8시

            let book = BookEntity(context: context)
            book.isbn = "SEED-\(index)"
            book.title = titles[index % titles.count]
            book.author = "테스트 저자"
            book.publisher = "테스트 출판사"
            book.createdAt = readAt

            let session = ReadingSessionEntity(context: context)
            session.id = UUID()
            session.startTime = readAt
            session.endTime = cal.date(byAdding: .minute, value: 10, to: readAt)
            session.duration = 600
            session.createdAt = readAt
            session.lightingHue = 40
            session.lightingSaturation = 20
            session.lightingBrightness = 80
            session.musicCategory = MusicCategory.warm.rawValue
            session.book = book

            day = cal.date(byAdding: .day, value: 1, to: day) ?? today.addingTimeInterval(86_400)
            index += 1
        }

        do {
            try context.save()
            print("[Seed] 스트릭 데이터 \(index)일치 시드 완료 (2026-07-03 ~ 오늘)")
        } catch {
            print("[Seed] 시드 저장 실패: \(error)")
        }
    }

    /// 지정 엔티티의 모든 오브젝트를 삭제(컨텍스트 경유 — 인메모리/실 스토어 모두 안전).
    private static func wipe(_ entities: [String], in context: NSManagedObjectContext) {
        for name in entities {
            let request = NSFetchRequest<NSManagedObject>(entityName: name)
            if let objects = try? context.fetch(request) {
                objects.forEach(context.delete)
            }
        }
    }
}
#endif
