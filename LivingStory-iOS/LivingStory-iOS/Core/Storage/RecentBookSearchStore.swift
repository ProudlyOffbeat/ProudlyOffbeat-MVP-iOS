//
//  RecentBookSearchStore.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 7/13/26.
//

import Foundation

/// 직접(수동) 책 검색에서 선택한 책의 최근 검색 저장소 (UserDefaults + JSON).
/// - 최대 8개 · ISBN 중복 제거 · 최신순(FIFO)
/// - 기기당 1유저 전제이므로 UserDefaults로 충분하다.
/// - 표시·재선택에 필요한 전체 정보를 담기 위해 `BookProfileModel`을 그대로 저장한다.
enum RecentBookSearchStore {

    static let maxCount = 8

    private static let key = "recentBookSearches"
    private static let defaults: UserDefaults = .standard

    /// 저장된 최근 검색 목록 (최신순).
    static func load() -> [BookProfileModel] {
        guard
            let data = defaults.data(forKey: key),
            let books = try? JSONDecoder().decode([BookProfileModel].self, from: data)
        else {
            return []
        }
        return books
    }

    /// 최근 검색에 추가. 동일 ISBN은 제거 후 맨 앞으로 올리고, 최대 `maxCount`개만 유지한다.
    static func add(_ book: BookProfileModel) {
        var books = load()
        books.removeAll { $0.isbn == book.isbn }
        books.insert(book, at: 0)
        if books.count > maxCount {
            books = Array(books.prefix(maxCount))
        }
        save(books)
    }

    /// 최근 검색 항목 삭제.
    static func remove(isbn: String) {
        var books = load()
        books.removeAll { $0.isbn == isbn }
        save(books)
    }

    /// 최근 검색 전체 삭제.
    static func clear() {
        defaults.removeObject(forKey: key)
    }

    private static func save(_ books: [BookProfileModel]) {
        guard let data = try? JSONEncoder().encode(books) else { return }
        defaults.set(data, forKey: key)
    }
}
