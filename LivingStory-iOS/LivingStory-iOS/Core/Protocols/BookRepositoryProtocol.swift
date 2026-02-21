//
//  BookRepositoryProtocol.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation

protocol BookRepositoryProtocol {
    func saveBook(_ book: BookProfileModel) throws
    func fetchAllBooks() throws -> [BookProfileModel]
    func findBook(by isbn: String) throws -> BookProfileModel?
    func deleteBook(by isbn: String) throws
}
