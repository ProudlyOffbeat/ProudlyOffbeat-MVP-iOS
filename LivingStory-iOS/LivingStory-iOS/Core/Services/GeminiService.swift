//
//  GeminiService.swift
//  LivingStory-iOS
//

import Foundation

// MARK: - Service

/// AIService의 Gemini 구현체(어댑터).
/// 프로바이더 고유의 응답 DTO와 오류는 이 안에서 도메인 타입·`AIServiceError`로 변환해
/// 호출부로 새어나가지 않게 한다.
final class GeminiService: AIService {

    private let session: URLSession
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - AIService
    //
    // 왜 둘로 나눴나: Gemini는 google_search(그라운딩)와 responseMimeType=json(JSON 강제)을
    // 동시에 못 쓴다. 질문은 책 내용을 웹검색해야 좋고(그라운딩 ON), 조명·음악은 정형 데이터라
    // JSON으로 받는 게 안전하다(그라운딩 OFF). 그래서 호출을 분리하고, 호출부에서 병렬로 돌린다.
    // (두 함수는 서로 독립적이라 async let 등으로 동시에 await 하면 wall-clock 손해가 없다.)

    /// 호출 A — 책을 웹검색으로 조사해 연령 맞춤 질문 3개를 생성한다.
    /// 그라운딩 ON이라 JSON 강제가 불가능 → "번호) 질문 || 효과" 번호줄 텍스트를 정규식으로 파싱한다.
    /// - Parameter age: 아이 나이(연령별 질문 깊이 기준표 적용).
    func generateQuestions(for book: BookProfileModel, age: Int) async throws -> [ConversationProfile] {
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
        // 프로바이더 DTO → 도메인 타입 변환은 여기서 끝낸다 (호출부로 DTO를 넘기지 않음)
        return try parseQuestions(from: text).map { $0.toProfile() }
    }

    /// 호출 B — 책 분위기에 맞는 조명(HSB)과 음악 카테고리를 선정한다.
    /// 그라운딩 OFF + JSON 강제라 응답을 곧장 디코딩한다.
    func generateEnvironment(for book: BookProfileModel) async throws -> AIEnvironment {
        let prompt = GeminiPrompts.lightingAndMusic(
            bookTitle: book.bookTitle,
            bookDescription: book.bookDescription
        )

        let url = try buildURL()
        let request = try buildRequest(url: url, prompt: prompt, grounding: false, jsonMode: true)

        let (data, response) = try await performRequest(request)
        try validateResponse(response, data: data)

        let text = try extractText(from: data)
        let result = try decode(LightingMusicResult.self, from: text)
        return AIEnvironment(lighting: result.lighting, musicCategory: result.musicCategory)
    }

    // MARK: - Private

    private func buildURL() throws -> URL {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [URLQueryItem(name: "key", value: Config.geminiAPIKey)]
        guard let url = components?.url else { throw AIServiceError.invalidConfiguration }
        return url
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
            throw AIServiceError.network(error.localizedDescription)
        }
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.server(statusCode: -1)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let body = String(data: data, encoding: .utf8) {
                print("[Gemini] 에러 응답 본문: \(body)")
            }
            throw AIServiceError.fromStatusCode(httpResponse.statusCode)
        }
    }

    private func extractText(from data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw AIServiceError.emptyResponse
        }
        return text
    }

    /// 마크다운 펜스(```json … ```)를 걷어내고 JSON으로 디코딩하는 공용 헬퍼.
    private func decode<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw AIServiceError.emptyResponse
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw AIServiceError.decoding(error.localizedDescription)
        }
    }

    /// 호출 A 응답(번호줄 텍스트)에서 "질문 || 효과"를 골라낸다. "1)", "2.", "3]" 등 번호 접두 허용.
    /// 그라운딩 응답엔 인용·잔말이 섞일 수 있어 번호줄만 정규식으로 추출한다(부분 복구 가능).
    /// 효과 구분자(||)가 빠진 줄은 질문만 살리고 효과는 빈 값으로 둔다(질문 손실 방지).
    private func parseQuestions(from text: String) throws -> [ConversationDTO] {
        let conversations: [ConversationDTO] = text
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard let range = trimmed.range(of: #"^\d+\s*[\).\]]\s*"#, options: .regularExpression) else {
                    return nil
                }
                let body = String(trimmed[range.upperBound...])
                let parts = body.components(separatedBy: "||")
                let question = parts[0].trimmingCharacters(in: .whitespaces)
                let effect = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : ""
                return question.isEmpty ? nil : ConversationDTO(question: question, effect: effect)
            }

        guard !conversations.isEmpty else {
            throw AIServiceError.decoding("질문 파싱 실패 (번호줄 형식 없음)")
        }
        return conversations
    }
}
