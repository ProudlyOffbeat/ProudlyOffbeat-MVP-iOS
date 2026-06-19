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
            Color(hex: 0x1C1C1E).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    titleRow
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    monthlySummary
                        .padding(.horizontal, 20)
                        .padding(.top, 40)

                    MultiSelectCalendarView()
                        .padding(.top, 88)

                    Divider()
                        .overlay(Color.white.opacity(0.1))
                        .padding(.horizontal, 8)

                    totalBooksSection
                        .padding(.top, 24)
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
                    // TODO: 설정 시트
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Title + Streak (디자인 Title and Subtitle 영역)

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(StringLiterals.My.summaryTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            flameBadge
        }
    }

    private var flameBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 16))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xFFCB24), Color(hex: 0xBFEE68)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("\(flameCount)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Monthly Summary (물결 그래프)

    private var monthlySummary: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(monthLabel)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(white: 0.92).opacity(0.6))
                Text(StringLiterals.My.monthlyReadIntro)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(.top, 12)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(monthlyCount)")
                        .font(.system(size: 56, weight: .medium))
                    Text(StringLiterals.My.readingUnit)
                        .font(.system(size: 30, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Total Books

    private var totalBooksSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Text(StringLiterals.My.totalReadBooks)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                Text("\(totalReadCount)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
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
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.move(to: CGPoint(x: 0, y: h * 0.6))
                path.addCurve(
                    to: CGPoint(x: w * 0.5, y: h * 0.55),
                    control1: CGPoint(x: w * 0.2, y: h * 0.5),
                    control2: CGPoint(x: w * 0.3, y: h * 0.7)
                )
                path.addCurve(
                    to: CGPoint(x: w, y: h * 0.05),
                    control1: CGPoint(x: w * 0.72, y: h * 0.38),
                    control2: CGPoint(x: w * 0.82, y: h * 0.1)
                )
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: 0xFFCB24), Color(hex: 0xBFEE68), Color(hex: 0x5AC8E8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 10, lineCap: .round)
            )
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
                .font(.system(size: 14, weight: .medium))
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
                    Color(hex: 0x2C2C2E)
                }
            }
        } else {
            Color(hex: 0x2C2C2E)
        }
    }
}

// MARK: - Stat Card (현재 미사용 — 추후 재사용 대비 보존)

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var isWide: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
            if !isWide {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.subheadlineRegular)
                    Text(value).font(.subheadlineEmphasized)
                }
            } else {
                HStack {
                    Text(title).font(.subheadlineRegular)
                    Spacer()
                    Text(value).font(.subheadlineEmphasized)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
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
