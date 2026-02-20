//
//  BookRecord.swift
//  LivingStory-iOS
//
//  임시 도메인 모델 (추후 CoreData Entity로 교체)
//

import Foundation

struct BookRecord {
    let isbn: String
    let title: String
    let author: String
    let publication: String
    let coverURL: String?
    let description: String?
    let createdAt: Date

    static let mock = BookRecord(
        isbn: "978-89-6546-359-7",
        title: "냉장고 먹는 괴물",
        author: "이현욱",
        publication: "밝은미래",
        coverURL: "https://image.aladin.co.kr/product/23861/33/cover500/8965463599_1.jpg",
        description: "무시무시한 괴물이 동네 냉장고를 집집마다 먹어 치우자, 냉장고 없이 살게 된 사람들이 오히려 건강한 삶을 되찾게 되는 환경 그림책입니다.",
        createdAt: Date()
    )
}

// MARK: - BookProfileModel 변환

extension BookRecord {
    func toProfileModel() -> BookProfileModel {
        BookProfileModel(
            isbn: isbn,
            bookCoverImageURL: coverURL.flatMap { URL(string: $0) },
            bookTitle: title,
            bookAuthor: author,
            bookPublisher: publication,
            bookDescription: description ?? ""
        )
    }
}
