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
}
