//
//  KakaoBookDTO.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

struct KakaoBookResponse: Decodable {
    let documents: [KakaoBookDocument]
    let meta: KakaoMeta
}

struct KakaoBookDocument: Decodable {
    let title: String
    let contents: String
    let thumbnail: String
    let authors: [String]
    let isbn: String
    let publisher: String
}

struct KakaoMeta: Decodable {
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
}
