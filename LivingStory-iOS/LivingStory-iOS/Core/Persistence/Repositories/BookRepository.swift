//
//  BookRepository.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/21/26.
//

import Foundation
import CoreData

final class BookRepository: BookRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
    }
    
    // MARK: - 저장 (Upsert)

    func saveBook(_ book: BookProfileModel) throws {
        let entity = try findEntity(by: book.isbn) ?? BookEntity(context: context)
        entity.update(with: book)
        try context.save()
    }

    // MARK: - 전체 조회

    func fetchAllBooks() throws -> [BookProfileModel] {
        let request = BookEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let entities = try context.fetch(request)
        return entities.map { $0.toProfile() }
    }

    // MARK: - ISBN으로 1건 조회

    func findBook(by isbn: String) throws -> BookProfileModel? {
        try findEntity(by: isbn)?.toProfile()
    }

    // MARK: - 삭제

    func deleteBook(by isbn: String) throws {
        guard let entity = try findEntity(by: isbn) else { return }
        context.delete(entity)
        try context.save()
    }

    // MARK: - Private

    private func findEntity(by isbn: String) throws -> BookEntity? {
        let request = BookEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isbn == %@", isbn)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
