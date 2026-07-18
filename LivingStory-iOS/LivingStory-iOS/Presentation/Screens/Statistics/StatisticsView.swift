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

    // 상태/로직은 ViewModel로 분리 (StatisticsViewModel)
    @State private var viewModel: StatisticsViewModel

    init(coordinator: AppCoordinator, repository: ReadingSessionRepositoryProtocol) {
        self.coordinator = coordinator
        _viewModel = State(initialValue: StatisticsViewModel(repository: repository))
    }

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

                    MultiSelectCalendarView(
                        readDates: viewModel.readDates,
                        today: Date(),
                        minMonth: viewModel.earliestMonth
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
        .onAppear { viewModel.load() }
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
            Text("\(viewModel.flameCount)")
                .font(.body2SemiBold)
                .foregroundStyle(.white)
        }
    }

    // MARK: - Monthly Summary (물결 그래프)

    private var monthlySummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "xxxx년 x월"
            Text(viewModel.monthLabel)
                .font(.calloutRegular)
                .foregroundStyle(Color(white: 0.92).opacity(0.6))
                .padding(.horizontal, 20)

            // 웨이브(풀블리드, 자연 비율) 위에 본문(문구+카운트)을 얹는다.
            // 웨이브 top = 년월 바텀 +16. 배경 대신 실제 레이아웃 요소여야 전체 너비를 받아 안 줄어듦.
            ZStack(alignment: .topLeading) {
                SummaryWave()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                summaryBody
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 년월 아래 본문 — 이번 달 문구 + 카운트. (웨이브 배경의 앵커 영역)
    private var summaryBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(StringLiterals.My.monthlyReadIntro)
                .font(.body1Regular)
                .foregroundStyle(.white)
                .padding(.top, 12)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(viewModel.monthlyCount)")
                    .font(.largeTitleMedium)
                Text(StringLiterals.My.readingUnit)
                    .font(.title2Medium)
            }
            .foregroundStyle(.white)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Total Books

    private var totalBooksSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Text(StringLiterals.My.totalReadBooks)
                    .font(.body2Medium)
                    .foregroundStyle(.white)
                Text("\(viewModel.totalReadCount)")
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
                    ForEach(Array(viewModel.readBooks.enumerated()), id: \.offset) { _, book in
                        StatBookThumbnail(coverURL: book.bookCoverImageURL, title: book.bookTitle)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Summary Wave (Figma 955:3088 웨이브 — IntroMy png 에셋, 좌→우로 드러남)

private struct SummaryWave: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        Image(.introMy)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            // 좌→우 리빌: 마스크 사각형을 왼쪽 고정으로 0→1 가로 스케일
            .mask(
                Rectangle()
                    .scaleEffect(x: progress, anchor: .leading)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1)) {
                    progress = 1
                }
            }
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
