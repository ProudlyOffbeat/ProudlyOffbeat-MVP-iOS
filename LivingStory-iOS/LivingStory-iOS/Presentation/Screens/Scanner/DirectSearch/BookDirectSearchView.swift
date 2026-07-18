//
//  BookDirectSearchView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 7/13/26.
//
//  바코드 스캔 실패 시 "직접 검색" — 제목·저자로 책을 찾아 선택하는 바텀시트.
//  · 검색어 없음: 최근 검색(가로 썸네일)
//  · 검색어 있음: 카카오 통합 검색 결과(세로 리스트) → 선택 시 하단 "책 선택" CTA

import SwiftUI

struct BookDirectSearchView: View {

    /// 책 선택 확정 (기존 바코드 성공 플로우로 진입).
    let onSelect: (BookProfileModel) -> Void
    /// 닫기 (스캐너 실패 화면으로 복귀).
    let onClose: () -> Void

    @State private var viewModel = BookDirectSearchViewModel()
    @FocusState private var isSearchFocused: Bool

    // 디자인 토큰
    private let labelSecondary = Color(hex: 0xEBEBF5, alpha: 0.7)   // Labels/Secondary
    private let iconGray = Color(hex: 0x8A8A8A)                     // Labels - Vibrant/Secondary
    private let fieldFill = Color(hex: 0x787880, alpha: 0.32)       // Fills/Secondary

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchField
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                ScrollView {
                    Group {
                        if viewModel.isSearching {
                            resultsSection
                        } else {
                            recentSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 36)
                    .padding(.bottom, 120) // CTA 가림 방지
                }
            }

            if let book = viewModel.selectedBook {
                selectButton(for: book)
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("책 선택")
                .font(.headlineRegular)
                .foregroundStyle(Color(hex: 0xF5F5F5))

            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(iconGray)
                        .frame(width: 44, height: 44)
                        .background(fieldFill, in: Circle())
                }
                Spacer()
            }
            .padding(.leading, 16)
        }
        .frame(height: 44)
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(iconGray)

            TextField(
                "",
                text: $viewModel.query,
                prompt: Text("책 제목 또는 저자 이름").foregroundStyle(iconGray)
            )
            .font(.headlineRegular)
            .foregroundStyle(.white)
            .tint(Color(hex: 0xBFEE68))
            .focused($isSearchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .onChange(of: viewModel.query) { _, _ in viewModel.queryChanged() }

            Image(systemName: "mic.fill")
                .foregroundStyle(iconGray)
        }
        .font(.headlineRegular)
        .padding(11)
        .background(fieldFill, in: Capsule())
    }

    // MARK: - Recent (가로)

    @ViewBuilder
    private var recentSection: some View {
        if !viewModel.recentBooks.isEmpty {
            VStack(alignment: .leading, spacing: 13) {
                Text("최근 검색")
                    .font(.labelRegular)
                    .foregroundStyle(labelSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.recentBooks, id: \.isbn) { book in
                            RecentBookCell(book: book, secondaryColor: labelSecondary)
                                .onTapGesture { confirm(book) }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Results (세로)

    @ViewBuilder
    private var resultsSection: some View {
        if viewModel.results.isEmpty {
            if viewModel.isLoading {
                ProgressView()
                    .tint(iconGray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                Text("검색 결과가 없어요")
                    .font(.calloutRegular)
                    .foregroundStyle(labelSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }
        } else {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.results, id: \.isbn) { book in
                    SearchResultRow(
                        book: book,
                        isSelected: viewModel.selectedISBN == book.isbn,
                        secondaryColor: labelSecondary
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.select(book) }
                }
            }
        }
    }

    // MARK: - CTA

    private func selectButton(for book: BookProfileModel) -> some View {
        Button {
            confirm(book)
        } label: {
            Text("책 선택")
                .font(.buttonMedium)
                .foregroundStyle(Color(hex: 0xF5F5F5))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black, in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Action

    private func confirm(_ book: BookProfileModel) {
        viewModel.commit(book)
        onSelect(book)
    }
}

// MARK: - Recent Cell (가로 썸네일)

private struct RecentBookCell: View {
    let book: BookProfileModel
    let secondaryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            BookCoverImage(url: book.bookCoverImageURL, cornerRadius: 4)
                .frame(width: 90, height: 120)

            VStack(alignment: .leading, spacing: 8) {
                Text(book.bookTitle)
                    .font(.calloutMedium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(book.bookAuthor)
                    .font(.calloutLight)
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)
            }
            .frame(width: 90, alignment: .leading)
        }
    }
}

// MARK: - Result Row (세로 리스트)

private struct SearchResultRow: View {
    let book: BookProfileModel
    let isSelected: Bool
    let secondaryColor: Color

    var body: some View {
        HStack(spacing: 16) {
            BookCoverImage(url: book.bookCoverImageURL, cornerRadius: 6)
                .frame(width: 54, height: 72)

            VStack(alignment: .leading, spacing: 8) {
                Text(book.bookTitle)
                    .font(.body2Medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(book.bookAuthor)
                    .font(.calloutRegular)
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: 0xBFEE68), lineWidth: 1)
            }
        }
    }
}

// MARK: - Cover Image

private struct BookCoverImage: View {
    let url: URL?
    let cornerRadius: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Color(hex: 0x2C2C2E)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Preview

#Preview {
    BookDirectSearchView(onSelect: { _ in }, onClose: {})
        .preferredColorScheme(.dark)
}
