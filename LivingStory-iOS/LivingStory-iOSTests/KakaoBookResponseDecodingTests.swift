//
//  KakaoBookResponseDecodingTests.swift
//  LivingStory-iOSTests
//
//  네트워크 스텁(URLProtocol)으로 카카오 응답을 주입해 DTO 디코딩 계약을 검증한다.
//  실서버·네트워크에 의존하지 않고 오프라인·결정적으로 돈다.
//  (ISBNLookupService end-to-end 스텁은 NetworkService의 URLSession 주입이 선행되어야 함 — 후속)
//

import XCTest
@testable import LivingStory_iOS

/// 지정한 데이터/상태코드를 즉시 돌려주는 테스트용 URLProtocol.
final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var stubData: Data?
    nonisolated(unsafe) static var stubStatus: Int = 200

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://stub.local")!,
            statusCode: Self.stubStatus,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = Self.stubData {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class KakaoBookResponseDecodingTests: XCTestCase {

    private func stubbedSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }

    override func tearDown() {
        URLProtocolStub.stubData = nil
        URLProtocolStub.stubStatus = 200
        super.tearDown()
    }

    func test_정상응답_디코딩_및_snakeCase매핑() async throws {
        let json = """
        {
          "documents": [
            {
              "title": "별 헤는 밤",
              "contents": "밤하늘 이야기",
              "thumbnail": "https://search1.kakaocdn.net/.../R120x174.jpg?q85",
              "authors": ["윤동주"],
              "isbn": "8912345 9788912345678",
              "publisher": "펭귄"
            }
          ],
          "meta": { "total_count": 1 }
        }
        """.data(using: .utf8)!
        URLProtocolStub.stubData = json

        let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=별")!
        let (data, _) = try await stubbedSession().data(for: URLRequest(url: url))
        let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)

        XCTAssertEqual(decoded.documents.count, 1)
        XCTAssertEqual(decoded.meta.totalCount, 1)                       // total_count → totalCount
        let doc = try XCTUnwrap(decoded.documents.first)
        XCTAssertEqual(doc.title, "별 헤는 밤")
        XCTAssertEqual(doc.authors.first, "윤동주")
        XCTAssertTrue(doc.isbn.contains("9788912345678"))               // ISBN13 포함(공백 구분)
    }

    func test_빈결과_디코딩() async throws {
        let json = #"{ "documents": [], "meta": { "total_count": 0 } }"#.data(using: .utf8)!
        URLProtocolStub.stubData = json

        let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=없는책")!
        let (data, _) = try await stubbedSession().data(for: URLRequest(url: url))
        let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)

        XCTAssertTrue(decoded.documents.isEmpty)
        XCTAssertEqual(decoded.meta.totalCount, 0)
    }
}
