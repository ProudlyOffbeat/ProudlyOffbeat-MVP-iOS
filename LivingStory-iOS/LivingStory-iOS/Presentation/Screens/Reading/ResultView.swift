//
//  ResultView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/12/26.
//
//  책 읽기 종료 → 결과창 (디자인 2635 / 2669)
//

import SwiftUI

struct ResultView: View {

    let coordinator: AppCoordinator
    let repository: ReadingSessionRepositoryProtocol

    // TODO: 연속일(streak) 데이터 연동 — 현재 더미 고정값
    private let flameCount = 12

    private var todaySessions: [ReadingSessionProfile] {
        (try? repository.fetchTodaySessions()) ?? []
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                flameRow

                Spacer().frame(height: 52)

                BookStackAnimationView()

                Spacer().frame(height: 30)

                Text(StringLiterals.Reading.todayReadBooks(todaySessions.count))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .tracking(0.5)

                Spacer().frame(height: 52)

                bookThumbnails

                Spacer()

                PrimaryButtonSwiftUI(title: StringLiterals.Reading.homeButton) {
                    coordinator.popToHome()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            // 하단 버튼을 물리 화면 바닥에서 30pt에 고정 (다른 화면과 통일)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            // 제목 색을 시스템 네비바(앱 라이트 고정→검정)에 맡기지 않고 흰색 콘텐츠로 직접 렌더
            ToolbarItem(placement: .principal) {
                Text(StringLiterals.Reading.resultTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Subviews

    private var flameRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BookStackAnimationView.gradientColors[0], // 노랑
                            BookStackAnimationView.gradientColors[1]   // 연두
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("\(flameCount)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var bookThumbnails: some View {
        let books = todaySessions.map(\.bookProfile)
        if !books.isEmpty {
            // 적으면 가운데 정렬, 많으면(6권 등) 가로 스크롤
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(Array(books.enumerated()), id: \.offset) { _, book in
                            ResultBookThumbnail(coverURL: book.bookCoverImageURL, title: book.bookTitle)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(minWidth: geo.size.width, alignment: .center)
                }
            }
            .frame(height: 124)
        }
    }
}

// MARK: - Book Thumbnail

private struct ResultBookThumbnail: View {
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

// MARK: - Preview

#if DEBUG
private struct PreviewResultRepository: ReadingSessionRepositoryProtocol {
    func saveSession(_ session: ReadingSessionProfile, bookISBN: String) throws {}
    func fetchAllSessions() throws -> [ReadingSessionProfile] { ReadingSessionProfile.mockList }
    func findSession(by id: UUID) throws -> ReadingSessionProfile? { nil }
    func deleteSession(by id: UUID) throws {}
    func fetchTodaySessions() throws -> [ReadingSessionProfile] {
        // 가로 스크롤 확인용 6권
        (0..<6).map { _ in ReadingSessionProfile.mock }
    }
    func fetchMonthlyBookCount() throws -> Int { 5 }
    func fetchTotalBookCount() throws -> Int { 12 }
    func fetchTotalSeconds() throws -> Int { 3600 }
    func fetchReadDates() throws -> Set<DateComponents> { [] }
}

#Preview {
    NavigationStack {
        ResultView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            repository: PreviewResultRepository()
        )
    }
}
#endif
