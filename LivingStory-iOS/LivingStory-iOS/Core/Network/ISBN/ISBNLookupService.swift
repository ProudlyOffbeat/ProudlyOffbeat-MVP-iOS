//
//  ISBNLookupService.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

final class ISBNLookupService {

    static let shared = ISBNLookupService()
    private let network = NetworkService.shared
    private init() {}

    func lookupBook(isbn: String) async throws -> BookProfileModel {
        var components = URLComponents(string: "https://dapi.kakao.com/v3/search/book")!
        components.queryItems = [
            URLQueryItem(name: "query", value: isbn),
            URLQueryItem(name: "target", value: "isbn"),
            URLQueryItem(name: "size", value: "1")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "KakaoAK \(Config.kakaoRESTAPIKey)",
            forHTTPHeaderField: "Authorization"
        )

        let response: KakaoBookResponse = try await network.request(request)

        guard let doc = response.documents.first else {
            throw NetworkError.noData
        }

        return BookProfileModel(
            isbn: isbn,
            bookCoverImageURL: URL(string: highResImageURL(from: doc.thumbnail)),
            bookTitle: doc.title,
            bookAuthor: doc.authors.joined(separator: ", "),
            bookPublisher: doc.publisher,
            bookDescription: doc.contents
        )
    }

    /// 제목·저자 통합 검색 (바코드 스캔 실패 시 직접 검색용)
    /// - `target` 파라미터를 생략하면 카카오가 제목/저자/출판사를 통합 검색한다.
    func searchBooks(query: String) async throws -> [BookProfileModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var components = URLComponents(string: "https://dapi.kakao.com/v3/search/book")!
        components.queryItems = [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "size", value: "10")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "KakaoAK \(Config.kakaoRESTAPIKey)",
            forHTTPHeaderField: "Authorization"
        )

        let response: KakaoBookResponse = try await network.request(request)

        return response.documents.map { doc in
            BookProfileModel(
                isbn: preferredISBN(from: doc.isbn),
                bookCoverImageURL: URL(string: highResImageURL(from: doc.thumbnail)),
                bookTitle: doc.title,
                bookAuthor: doc.authors.joined(separator: ", "),
                bookPublisher: doc.publisher,
                bookDescription: doc.contents
            )
        }
    }
}

// MARK: - Private Methods

private extension ISBNLookupService {

    /// 카카오 썸네일 URL 고화질 변환
    /// R120x174 (기본 작은 썸네일) → R480x0 (폭 480, 높이 자동)
    func highResImageURL(from thumbnailURLString: String) -> String {
        thumbnailURLString
            .replacingOccurrences(of: "R120x174", with: "R480x0")
            .replacingOccurrences(of: "q85", with: "q100")
    }

    /// 카카오 검색 결과의 `isbn` 필드는 "ISBN10 ISBN13" 형태의 공백 구분 문자열이다.
    /// 책의 안정적 식별을 위해 ISBN13(13자리)을 우선 사용하고,
    /// 없으면 마지막 토큰, 그마저 없으면 원본을 그대로 반환한다.
    func preferredISBN(from raw: String) -> String {
        let tokens = raw.split(separator: " ").map(String.init)
        if let isbn13 = tokens.first(where: { $0.count == 13 }) {
            return isbn13
        }
        return tokens.last ?? raw
    }
}
