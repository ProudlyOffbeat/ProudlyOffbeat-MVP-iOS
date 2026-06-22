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

    // TODO: 실제 데이터 연동 (현재 전부 더미)
    private let flameCount = 12
    private let monthLabel = "2026년 10월"
    private let monthlyCount = 23
    private let totalReadCount = 18
    private let dummyBooks: [BookProfileModel] = [.mock, .mockISBN, .mock, .mockISBN, .mock]

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

                    MultiSelectCalendarView()

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
                    ForEach(Array(dummyBooks.enumerated()), id: \.offset) { _, book in
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
    func fetchAllSessions() throws -> [ReadingSessionProfile] { [] }
    func findSession(by id: UUID) throws -> ReadingSessionProfile? { nil }
    func deleteSession(by id: UUID) throws {}
    func fetchTodaySessions() throws -> [ReadingSessionProfile] { [] }
    func fetchMonthlyBookCount() throws -> Int { 23 }
    func fetchTotalBookCount() throws -> Int { 18 }
    func fetchTotalSeconds() throws -> Int { 0 }
    func fetchReadDates() throws -> Set<DateComponents> { [] }
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
