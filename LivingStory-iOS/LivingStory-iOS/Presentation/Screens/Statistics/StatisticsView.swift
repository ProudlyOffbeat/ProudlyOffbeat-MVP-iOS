//
//  StatisticsView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//
//  내 독서 요약 (디자인 897-4729) — 현재 UI만, 데이터 더미
//

import SwiftUI

struct StatisticsView: View {

    let coordinator: AppCoordinator
    let repository: ReadingSessionRepositoryProtocol

    // 실제 데이터 (onAppear에서 리포지토리로 로드)
    @State private var flameCount = 0          // 연속 독서일(스트릭) — 저장값이 아니라 읽은 날짜로 계산
    @State private var monthlyCount = 0         // 이번 달 읽어준 횟수(세션 수)
    @State private var totalReadCount = 0       // 누적 고유 책 수(중복 제외)
    @State private var readBooks: [BookProfileModel] = []  // 누적 고유 책 목록(최근 순)
    @State private var readDates: Set<DateComponents> = [] // 책 읽은 날짜(달력 표시용)
    @State private var earliestMonth: Date? = nil         // 최초 독서월(달력 과거 슬라이드 하한)

    /// 상단 "이번 달" 라벨 — 현재 월을 한국어로 표시 (yyyy년 M월)
    private let monthLabel: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: Date())
    }()

    var body: some View {
        ZStack {
            Color.backgroundSecondary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    titleRow
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    monthlySummary
                        .padding(.top, 40)
                        .background(alignment: .top) {
                            SummaryWave()
                                .frame(maxWidth: .infinity)
                        }

                    MultiSelectCalendarView(
                        readDates: readDates,
                        today: Date(),
                        minMonth: earliestMonth
                    )

                    Divider()
                        .overlay(Color.white.opacity(0.1))
                        .padding(.horizontal, 8)

                    totalBooksSection
                        .padding(.top, 34)
                        .padding(.bottom, 24)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { load() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.showSettings()
                } label: {
                    Image(.settingsFill)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Data Loading

    /// 화면 진입 시 리포지토리에서 실제 통계를 읽어 상태에 채운다.
    /// 새 세션이 저장된 뒤 탭으로 돌아와도 최신 값이 반영되도록 onAppear마다 호출.
    private func load() {
        let dates = (try? repository.fetchReadDates()) ?? []
        readDates = dates
        flameCount = Self.currentStreak(from: dates, today: Date())
        earliestMonth = Self.earliestMonth(from: dates)

        monthlyCount = (try? repository.fetchMonthlyBookCount()) ?? 0
        totalReadCount = (try? repository.fetchTotalBookCount()) ?? 0
        readBooks = Self.uniqueBooks(from: (try? repository.fetchAllSessions()) ?? [])
    }

    /// 연속 독서일(스트릭). 오늘부터 거꾸로 "읽은 날"이 끊기지 않은 일수.
    /// 오늘 아직 안 읽었으면 어제부터 세기 시작(그날이 끝나기 전 스트릭을 잃지 않게).
    static func currentStreak(from readDates: Set<DateComponents>, today: Date) -> Int {
        let cal = Calendar(identifier: .gregorian)
        let readDays: Set<Date> = Set(readDates.compactMap { comps in
            guard let y = comps.year, let m = comps.month, let d = comps.day else { return nil }
            return cal.date(from: DateComponents(year: y, month: m, day: d))
        })
        guard !readDays.isEmpty else { return 0 }

        let todayStart = cal.startOfDay(for: today)
        var cursor: Date
        if readDays.contains(todayStart) {
            cursor = todayStart
        } else {
            // 그레이스: 오늘 미독서면 어제부터. 어제도 비었으면 스트릭 0.
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: todayStart),
                  readDays.contains(yesterday) else { return 0 }
            cursor = yesterday
        }

        var count = 0
        while readDays.contains(cursor) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

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

    // MARK: - Title + Streak (디자인 Title and Subtitle 영역)

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(StringLiterals.My.summaryTitle)
                .font(.title1Emphasized)
                .foregroundStyle(.white)
            Spacer()
            flameBadge
        }
    }

    private var flameBadge: some View {
        HStack(spacing: 4) {
            Image(.flame)
                .font(.system(size: 16))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow20, .green0],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("\(flameCount)")
                .font(.body2SemiBold)
                .foregroundStyle(.white)
        }
    }

    // MARK: - Monthly Summary (물결 그래프)

    private var monthlySummary: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(monthLabel)
                    .font(.calloutRegular)
                    .foregroundStyle(Color(white: 0.92).opacity(0.6))
                Text(StringLiterals.My.monthlyReadIntro)
                    .font(.body1Regular)
                    .foregroundStyle(.white)
                    .padding(.top, 12)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(monthlyCount)")
                        .font(.largeTitleMedium)
                    Text(StringLiterals.My.readingUnit)
                        .font(.title2Medium)
                }
                .foregroundStyle(.white)
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 88)
    }

    // MARK: - Total Books

    private var totalBooksSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Text(StringLiterals.My.totalReadBooks)
                    .font(.body2Medium)
                    .foregroundStyle(.white)
                Text("\(totalReadCount)")
                    .font(.body2Regular)
                    .foregroundStyle(.white)
                Spacer()
                Image(.forward)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(white: 0.92).opacity(0.4))
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(readBooks.enumerated()), id: \.offset) { _, book in
                        StatBookThumbnail(coverURL: book.bookCoverImageURL, title: book.bookTitle)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Summary Wave (장식용 그라데이션 물결)

private struct SummaryWave: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        WaveShape()
            .trim(from: 0, to: progress)
            .stroke(
                LinearGradient(
                    colors: [.yellow20, .green0, Color(hex: 0x5AC8E8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1)) {
                    progress = 1
                }
            }
    }
}

/// 좌하단(낮음) → 우상단(높음)으로 솟는 물결 라인
private struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h * 0.72))
        path.addCurve(
            to: CGPoint(x: w * 0.42, y: h * 0.86),
            control1: CGPoint(x: w * 0.13, y: h * 0.66),
            control2: CGPoint(x: w * 0.27, y: h * 0.92)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.18),
            control1: CGPoint(x: w * 0.62, y: h * 0.80),
            control2: CGPoint(x: w * 0.82, y: h * 0.26)
        )
        return path
    }
}

// MARK: - Book Thumbnail

private struct StatBookThumbnail: View {
    let coverURL: URL?
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            cover
                .frame(width: 72, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(title)
                .font(.labelMedium)
                .foregroundStyle(.white)
                .opacity(0.7)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 72, alignment: .leading)
        }
    }

    @ViewBuilder
    private var cover: some View {
        if let coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color(.tertiarySystemBackground)
                }
            }
        } else {
            Color(.tertiarySystemBackground)
        }
    }
}

// MARK: - Color Helper

private extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Preview

#if DEBUG
private struct PreviewStatsRepository: ReadingSessionRepositoryProtocol {
    func saveSession(_ session: ReadingSessionProfile, bookISBN: String) throws {}
    func fetchAllSessions() throws -> [ReadingSessionProfile] { ReadingSessionProfile.mockList }
    func findSession(by id: UUID) throws -> ReadingSessionProfile? { nil }
    func deleteSession(by id: UUID) throws {}
    func fetchTodaySessions() throws -> [ReadingSessionProfile] { [] }
    func fetchMonthlyBookCount() throws -> Int { 23 }
    func fetchTotalBookCount() throws -> Int { 18 }
    func fetchTotalSeconds() throws -> Int { 0 }

    /// 프리뷰 더미: 오늘 포함 최근 연속 3일(스트릭 확인) + 3개월 전 1건(과거 슬라이드 하한 확인)
    func fetchReadDates() throws -> Set<DateComponents> {
        let cal = Calendar(identifier: .gregorian)
        let today = cal.startOfDay(for: Date())
        var dates = Set<DateComponents>()
        for offset in 0...2 {
            if let d = cal.date(byAdding: .day, value: -offset, to: today) {
                dates.insert(cal.dateComponents([.year, .month, .day], from: d))
            }
        }
        if let past = cal.date(byAdding: .month, value: -3, to: today) {
            dates.insert(cal.dateComponents([.year, .month, .day], from: past))
        }
        return dates
    }
}

#Preview {
    NavigationStack {
        StatisticsView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            repository: PreviewStatsRepository()
        )
    }
}
#endif
