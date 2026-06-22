//
//  GeminiService.swift
//  LivingStory-iOS
//

import Foundation

// MARK: - Error

enum GeminiError: LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case invalidResponse(statusCode: Int)
    case emptyResponse
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 API URL입니다."
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .invalidResponse(let code):
            if code == 429 {
                return "API 요청 한도 초과 - 잠시 후 다시 시도해주세요."
            }
            return "서버 응답 오류 (코드: \(code))"
        case .emptyResponse:
            return "Gemini 응답이 비어있습니다."
        case .decodingError(let message):
            return "응답 파싱 오류: \(message)"
        }
    }
}

// MARK: - Service

final class GeminiService: Sendable {

    private let session: URLSession
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateReadingEnvironment(for book: BookProfileModel) async throws -> ReadingEnvironment {
        let url = try buildURL()
        let request = try buildRequest(url: url, book: book)

        let (data, response) = try await performRequest(request)
        try validateResponse(response, data: data)

        let text = try extractText(from: data)
        return try decodeEnvironment(from: text)
    }

    // MARK: - 2-호출(병렬) API
    //
    // 왜 둘로 나눴나: Gemini는 google_search(그라운딩)와 responseMimeType=json(JSON 강제)을
    // 동시에 못 쓴다. 질문은 책 내용을 웹검색해야 좋고(그라운딩 ON), 조명·음악은 정형 데이터라
    // JSON으로 받는 게 안전하다(그라운딩 OFF). 그래서 호출을 분리하고, 호출부에서 병렬로 돌린다.
    // (두 함수는 서로 독립적이라 async let 등으로 동시에 await 하면 wall-clock 손해가 없다.)

    /// 호출 A — 책을 웹검색으로 조사해 연령 맞춤 질문 3개를 생성한다.
    /// 그라운딩 ON이라 JSON 강제가 불가능 → "1) 2) 3)" 번호줄 텍스트를 정규식으로 파싱한다.
    /// - Parameter age: 아이 나이(연령별 질문 깊이 기준표 적용).
    func generateQuestions(for book: BookProfileModel, age: Int) async throws -> [String] {
        let prompt = GeminiPrompts.questions(
            bookTitle: book.bookTitle,
            isbn: book.isbn,
            age: age,
            bookDescription: book.bookDescription
        )

        let url = try buildURL()
        let request = try buildRequest(url: url, prompt: prompt, grounding: true, jsonMode: false)

        let (data, response) = try await performRequest(request)
        try validateResponse(response, data: data)

        let text = try extractText(from: data)
        return try parseQuestions(from: text)
    }

    /// 호출 B — 책 분위기에 맞는 조명(HSB)과 음악 카테고리를 선정한다.
    /// 그라운딩 OFF + JSON 강제라 응답을 곧장 디코딩한다.
    func generateLightingAndMusic(for book: BookProfileModel) async throws -> LightingMusicResult {
        let prompt = GeminiPrompts.lightingAndMusic(
            bookTitle: book.bookTitle,
            bookDescription: book.bookDescription
        )

        let url = try buildURL()
        let request = try buildRequest(url: url, prompt: prompt, grounding: false, jsonMode: true)

        let (data, response) = try await performRequest(request)
        try validateResponse(response, data: data)

        let text = try extractText(from: data)
        return try decode(LightingMusicResult.self, from: text)
    }

    // MARK: - Private

    private func buildURL() throws -> URL {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [URLQueryItem(name: "key", value: Config.geminiAPIKey)]
        guard let url = components?.url else { throw GeminiError.invalidURL }
        return url
    }

    private func buildRequest(url: URL, book: BookProfileModel) throws -> URLRequest {
        let prompt = GeminiPrompts.readingEnvironment(
            bookTitle: book.bookTitle,
            bookDescription: book.bookDescription
        )

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "temperature": 0.7
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    /// 2-호출용 요청 빌더. grounding(웹검색)과 jsonMode(JSON 강제)는 함께 켤 수 없다(API 제약).
    private func buildRequest(url: URL, prompt: String, grounding: Bool, jsonMode: Bool) throws -> URLRequest {
        var body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        if grounding {
            body["tools"] = [["google_search": [String: Any]()]]
        }
        if jsonMode {
            body["generationConfig"] = ["responseMimeType": "application/json"]
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw GeminiError.networkError(error.localizedDescription)
        }
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse(statusCode: -1)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let body = String(data: data, encoding: .utf8) {
                print("[Gemini] 에러 응답 본문: \(body)")
            }
            throw GeminiError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }

    private func extractText(from data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.emptyResponse
        }
        return text
    }

    private func decodeEnvironment(from text: String) throws -> ReadingEnvironment {
        try decode(ReadingEnvironment.self, from: text)
    }

    /// 마크다운 펜스(```json … ```)를 걷어내고 JSON으로 디코딩하는 공용 헬퍼.
    private func decode<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.emptyResponse
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw GeminiError.decodingError(error.localizedDescription)
        }
    }

    /// 호출 A 응답(번호줄 텍스트)에서 질문만 골라낸다. "1)", "2.", "3]" 등 번호 접두를 허용.
    /// 그라운딩 응답엔 인용·잔말이 섞일 수 있어 번호줄만 정규식으로 추출한다(부분 복구 가능).
    private func parseQuestions(from text: String) throws -> [String] {
        let questions: [String] = text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard let range = trimmed.range(of: #"^\d+\s*[\).\]]\s*"#, options: .regularExpression) else {
                    return nil
                }
                let question = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                return question.isEmpty ? nil : question
            }

        guard !questions.isEmpty else {
            throw GeminiError.decodingError("질문 파싱 실패 (번호줄 형식 없음)")
        }
        return questions
    }
}
