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
}
