//
//  AIService.swift
//  LivingStory-iOS
//
//  AI 추천 서비스 추상화.
//  호출부가 특정 프로바이더(Gemini) 구현에 직접 의존하지 않도록 최소 인터페이스만 노출한다.
//  구현체 교체와 테스트 더블·프리뷰용 목 주입이 가능해진다.
//

import Foundation

// MARK: - Domain Types

/// AI가 추천한 독서 환경 (프로바이더 중립).
/// 프로바이더별 응답 DTO는 각 구현체 안에서 이 타입으로 변환한다.
struct AIEnvironment: Sendable {
    let lighting: LightingConfig
    let musicCategory: MusicCategory
}

// MARK: - Error

/// 프로바이더 중립 AI 오류. 호출부는 이 타입만 알면 된다.
/// 문구는 사용자 안내(graceful degradation)에 그대로 쓰인다.
enum AIServiceError: LocalizedError, Sendable {
    case invalidConfiguration
    case network(String)
    case rateLimited
    case server(statusCode: Int)
    case emptyResponse
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "잘못된 API 설정입니다."
        case .network(let message):
            return "네트워크 오류: \(message)"
        case .rateLimited:
            return "API 요청 한도 초과 - 잠시 후 다시 시도해주세요."
        case .server(let code):
            return "서버 응답 오류 (코드: \(code))"
        case .emptyResponse:
            return "AI 응답이 비어있습니다."
        case .decoding(let message):
            return "응답 파싱 오류: \(message)"
        }
    }

    /// HTTP 상태코드 → 오류 매핑 (429는 별도 취급)
    static func fromStatusCode(_ code: Int) -> AIServiceError {
        code == 429 ? .rateLimited : .server(statusCode: code)
    }
}

// MARK: - Protocol

/// 독서 환경 추천에 필요한 최소 인터페이스.
/// 호출부가 실제로 쓰는 두 가지만 노출한다.
protocol AIService: Sendable {

    /// 책을 조사해 연령에 맞는 대화 주제를 생성한다.
    func generateQuestions(for book: BookProfileModel, age: Int) async throws -> [ConversationProfile]

    /// 책 분위기에 맞는 조명과 음악 카테고리를 선정한다.
    func generateEnvironment(for book: BookProfileModel) async throws -> AIEnvironment
}
