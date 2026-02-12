//
//  GeminiService.swift
//  LivingStory-iOS
//

import Foundation

// MARK: - Error

enum GeminiError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case emptyResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 API URL입니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .invalidResponse(let code):
            if code == 429 {
                return "API 요청 한도 초과 - 잠시 후 다시 시도해주세요."
            }
            return "서버 응답 오류 (코드: \(code))"
        case .emptyResponse:
            return "Gemini 응답이 비어있습니다."
        case .decodingError(let error):
            return "응답 파싱 오류: \(error.localizedDescription)"
        }
    }
}

// MARK: - Service

nonisolated final class GeminiService: Sendable {

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

    // MARK: - Private

    private func buildURL() throws -> URL {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [URLQueryItem(name: "key", value: Secrets.geminiAPIKey)]
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

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw GeminiError.networkError(error)
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
        // JSON 마크다운 펜스 제거 (```json ... ```)
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.emptyResponse
        }

        do {
            return try JSONDecoder().decode(ReadingEnvironment.self, from: data)
        } catch {
            throw GeminiError.decodingError(error)
        }
    }
}
