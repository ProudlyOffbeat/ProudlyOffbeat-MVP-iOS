//
//  BookProfileModel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

struct BookProfileModel: Codable {
    let isbn: String
    let bookCoverImageURL: URL?
    let bookTitle: String
    let bookAuthor: String
    let bookPublisher: String
    let bookDescription: String

    static let mock = BookProfileModel(
        isbn: "9780156012195",
        bookCoverImageURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780156012195-L.jpg"),
        bookTitle: "완다는 별의 소리를 들어요",
        bookAuthor: "생텍쥐페리",
        bookPublisher: "문학동네",
        bookDescription: "사막에 불시착한 비행사가 별에서 온 왕자를 만나 대화하며, 여우에게 길들여짐과 관계의 소중한 책임감을 배운 뒤에, 사랑하는 장미가 있는 자신의 별로 돌아가는 이야기입니다."
    )

    static let mockISBN = BookProfileModel(
        isbn: "978-89-6546-359-7",
        bookCoverImageURL: URL(string: "https://image.aladin.co.kr/product/23861/33/cover500/8965463599_1.jpg"),
        bookTitle: "냉장고 먹는 괴물",
        bookAuthor: "이현욱",
        bookPublisher: "밝은미래",
        bookDescription: "무시무시한 괴물이 동네 냉장고를 집집마다 먹어 치우자, 냉장고 없이 살게 된 사람들이 오히려 건강한 삶을 되찾게 되는 환경 그림책입니다."
    )
}
