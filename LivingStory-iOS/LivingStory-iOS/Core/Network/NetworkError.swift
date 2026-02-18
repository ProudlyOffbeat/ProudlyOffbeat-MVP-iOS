//
//  NetworkError.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed
    case noData
}
