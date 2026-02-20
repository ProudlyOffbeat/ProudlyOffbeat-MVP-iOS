//
//  NetworkService.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

final class NetworkService {

    static let shared = NetworkService()
    private init() {}

    func request<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
