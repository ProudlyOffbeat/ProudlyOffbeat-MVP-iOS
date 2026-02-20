//
//  BookEntity+Extensions.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation
import CoreData

//MARK: - BookEntity -> BookProfileModel 변환 (읽기)
extension BookEntity {
    
    func toProfile() -> BookProfileModel {
        BookProfileModel(
            isbn: isbn ?? "",
            bookCoverImageURL: coverImageURL.flatMap {URL(string: $0) },
            bookTitle: title ?? "",
            bookAuthor: author ?? "",
            bookPublisher: publisher ?? "",
            bookDescription: bookDescription ?? ""
            )
    }
}

//MARK: - BookProfileModel -> BookEntity 변환 (저장)

extension BookEntity {
    
    func update(with profile: BookProfileModel) {
        isbn = profile.isbn
        title = profile.bookTitle
        author = profile.bookAuthor
        publisher = profile.bookPublisher
        coverImageURL = profile.bookCoverImageURL?.absoluteString
        bookDescription = profile.bookDescription
        if createdAt == nil {
            createdAt = Date()
        }
    }
    
}
