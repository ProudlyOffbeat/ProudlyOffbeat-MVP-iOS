//
//  AIServiceTests.swift
//  LivingStory-iOSTests
//
//  AIService 추상화 계약 검증.
//  - GeminiService(어댑터): 네트워크 스텁으로 응답·오류를 주입해 도메인 타입/중립 오류로 변환되는지 확인
//  - MockAIService: 프로토콜 대체 구현이 호출부 관점에서 동일하게 동작하는지 확인
//  URLProtocolStub은 KakaoBookResponseDecodingTests(PO-100)에서 정의한 것을 재사용한다.
//

import XCTest
@testable import LivingStory_iOS

final class AIServiceTests: XCTestCase {

    private func stubbedService() -> GeminiService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return GeminiService(session: URLSession(configuration: config))
    }

    /// Gemini 응답 봉투(candidates→content→parts→text)로 감싼다.
    private func geminiEnvelope(text: String) -> Data {
        let payload: [String: Any] = [
            "candidates": [
                ["content": ["parts": [["text": text]]]]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: payload)
    }

    private let book = BookProfileModel.mockISBN

    override func tearDown() {
        URLProtocolStub.stubData = nil
        URLProtocolStub.stubStatus = 200
        super.tearDown()
    }

    // MARK: - 오류 매핑 (프로바이더 오류 → 중립 오류)

    func test_429응답은_rateLimited로_매핑된다() async {
        URLProtocolStub.stubStatus = 429
        URLProtocolStub.stubData = Data("{}".utf8)

        do {
            _ = try await stubbedService().generateEnvironment(for: book)
            XCTFail("오류가 발생해야 한다")
        } catch let error as AIServiceError {
            guard case .rateLimited = error else {
                return XCTFail("rateLimited 여야 한다. 실제: \(error)")
            }
            XCTAssertEqual(error.errorDescription, "API 요청 한도 초과 - 잠시 후 다시 시도해주세요.")
        } catch {
            XCTFail("AIServiceError 여야 한다. 실제: \(error)")
        }
    }

    func test_500응답은_server로_매핑된다() async {
        URLProtocolStub.stubStatus = 500
        URLProtocolStub.stubData = Data("{}".utf8)

        do {
            _ = try await stubbedService().generateEnvironment(for: book)
            XCTFail("오류가 발생해야 한다")
        } catch let error as AIServiceError {
            guard case .server(let code) = error else {
                return XCTFail("server 여야 한다. 실제: \(error)")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("AIServiceError 여야 한다. 실제: \(error)")
        }
    }

    func test_응답봉투가_비면_emptyResponse로_매핑된다() async {
        URLProtocolStub.stubStatus = 200
        URLProtocolStub.stubData = Data("{}".utf8)

        do {
            _ = try await stubbedService().generateEnvironment(for: book)
            XCTFail("오류가 발생해야 한다")
        } catch let error as AIServiceError {
            guard case .emptyResponse = error else {
                return XCTFail("emptyResponse 여야 한다. 실제: \(error)")
            }
        } catch {
            XCTFail("AIServiceError 여야 한다. 실제: \(error)")
        }
    }

    // MARK: - 도메인 타입 변환 (DTO가 호출부로 새지 않는지)

    func test_조명음악_JSON이_AIEnvironment로_변환된다() async throws {
        let json = #"{"lighting":{"hue":40,"saturation":70,"brightness":60},"musicCategory":"Warm"}"#
        URLProtocolStub.stubData = geminiEnvelope(text: json)

        let env = try await stubbedService().generateEnvironment(for: book)

        XCTAssertEqual(env.lighting.hue, 40)
        XCTAssertEqual(env.lighting.saturation, 70)
        XCTAssertEqual(env.lighting.brightness, 60)
        XCTAssertEqual(env.musicCategory, .warm)
    }

    func test_마크다운_펜스로_감싼_JSON도_디코딩된다() async throws {
        let json = "```json\n{\"lighting\":{\"hue\":10,\"saturation\":20,\"brightness\":30},\"musicCategory\":\"Cozy\"}\n```"
        URLProtocolStub.stubData = geminiEnvelope(text: json)

        let env = try await stubbedService().generateEnvironment(for: book)

        XCTAssertEqual(env.lighting.hue, 10)
        XCTAssertEqual(env.musicCategory, .cozy)
    }

    func test_번호줄_응답이_ConversationProfile로_변환된다() async throws {
        let text = """
        1) 주인공은 왜 그런 선택을 했을까? || 공감 능력을 키워요
        2. 너라면 어떻게 했을 것 같아? || 자기 표현을 도와요
        3] 가장 기억에 남는 장면은? || 이야기를 정리해요
        """
        URLProtocolStub.stubData = geminiEnvelope(text: text)

        let questions = try await stubbedService().generateQuestions(for: book, age: 6)

        XCTAssertEqual(questions.count, 3)
        XCTAssertEqual(questions.first?.question, "주인공은 왜 그런 선택을 했을까?")
        XCTAssertEqual(questions.first?.effect, "공감 능력을 키워요")
    }

    func test_효과_구분자가_없으면_질문만_살린다() async throws {
        URLProtocolStub.stubData = geminiEnvelope(text: "1) 질문만 있는 줄")

        let questions = try await stubbedService().generateQuestions(for: book, age: 6)

        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions.first?.question, "질문만 있는 줄")
        XCTAssertEqual(questions.first?.effect, "")
    }

    func test_번호줄이_없으면_decoding오류로_매핑된다() async {
        URLProtocolStub.stubData = geminiEnvelope(text: "번호 없는 아무 문장")

        do {
            _ = try await stubbedService().generateQuestions(for: book, age: 6)
            XCTFail("오류가 발생해야 한다")
        } catch let error as AIServiceError {
            guard case .decoding = error else {
                return XCTFail("decoding 이어야 한다. 실제: \(error)")
            }
        } catch {
            XCTFail("AIServiceError 여야 한다. 실제: \(error)")
        }
    }

    // MARK: - 대체 구현 (추상화의 목적)

    func test_목_구현체가_프로토콜_자리에_들어간다() async throws {
        let service: any AIService = MockAIService()

        let env = try await service.generateEnvironment(for: book)
        let questions = try await service.generateQuestions(for: book, age: 6)

        XCTAssertEqual(env.musicCategory, AIEnvironment.mock.musicCategory)
        XCTAssertFalse(questions.isEmpty)
    }

    func test_목_구현체로_실패_경로를_재현한다() async {
        let service: any AIService = MockAIService(error: .rateLimited)

        do {
            _ = try await service.generateEnvironment(for: book)
            XCTFail("오류가 발생해야 한다")
        } catch let error as AIServiceError {
            guard case .rateLimited = error else {
                return XCTFail("rateLimited 여야 한다. 실제: \(error)")
            }
        } catch {
            XCTFail("AIServiceError 여야 한다. 실제: \(error)")
        }
    }

    // MARK: - 폴백 안내 문구 (graceful degradation)

    @MainActor
    func test_AIServiceError는_에러별_안내문구가_나온다() {
        XCTAssertEqual(
            ReadingViewModel.aiFallbackNotice(for: AIServiceError.rateLimited),
            "API 요청 한도 초과 - 잠시 후 다시 시도해주세요."
        )
        XCTAssertEqual(
            ReadingViewModel.aiFallbackNotice(for: AIServiceError.server(statusCode: 503)),
            "서버 응답 오류 (코드: 503)"
        )
    }

    @MainActor
    func test_알수없는_오류는_기본_안내문구로_떨어진다() {
        struct UnknownError: Error {}

        XCTAssertEqual(
            ReadingViewModel.aiFallbackNotice(for: UnknownError()),
            "AI 추천을 불러오지 못했어요. 잠시 후 다시 시도해주세요."
        )
    }
}
