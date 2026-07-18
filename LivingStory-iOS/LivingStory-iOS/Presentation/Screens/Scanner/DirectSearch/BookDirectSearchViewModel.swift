//
//  BookDirectSearchViewModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 7/13/26.
//

import Foundation
import Observation

/// 책 직접 검색 화면 상태.
/// - 검색어가 비어 있으면 최근 검색(가로) 모드
/// - 검색어가 있으면 카카오 통합 검색 결과(세로) 모드
@MainActor
@Observable
final class BookDirectSearchViewModel {

    var query = ""

    private(set) var results: [BookProfileModel] = []
    private(set) var recentBooks: [BookProfileModel] = []
    private(set) var isLoading = false

    /// 현재 선택된 결과의 ISBN (선택 시 하단 CTA 노출).
    private(set) var selectedISBN: String?

    private let service = ISBNLookupService.shared
    private var searchTask: Task<Void, Never>?

    /// 검색 모드 여부 (검색어 존재).
    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 하단 CTA에 사용할 선택된 책.
    var selectedBook: BookProfileModel? {
        guard let selectedISBN else { return nil }
        return results.first { $0.isbn == selectedISBN }
    }

    /// 화면 진입 시 최근 검색 로드.
    func onAppear() {
        recentBooks = RecentBookSearchStore.load()
    }

    /// 검색어 변경 → 0.3초 디바운스 후 카카오 검색. 최대 8개만 노출.
    func queryChanged() {
        selectedISBN = nil
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isLoading = false
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            self.isLoading = true
            defer { self.isLoading = false }

            do {
                let books = try await self.service.searchBooks(query: trimmed)
                guard !Task.isCancelled else { return }
                self.results = Array(books.prefix(RecentBookSearchStore.maxCount))
            } catch is CancellationError {
                return
            } catch {
                self.results = []
            }
        }
    }

    /// 검색 결과 항목 선택 (하단 CTA 노출용).
    func select(_ book: BookProfileModel) {
        selectedISBN = book.isbn
    }

    /// 선택 확정 → 최근 검색에 반영.
    func commit(_ book: BookProfileModel) {
        RecentBookSearchStore.add(book)
    }
}
