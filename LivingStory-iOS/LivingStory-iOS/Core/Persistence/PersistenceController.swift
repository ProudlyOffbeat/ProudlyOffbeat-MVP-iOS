//
//  PersistenceController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/20/26.
//

import CoreData

@MainActor
final class PersistenceController {
    
    //MARK: - 싱글톤
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    //MARK: - 초기화
    
    private init (inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NaruModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("CoreData 로드 실패 : \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    //MARK: 실제 SQLite에 저장하는 함수
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData 저장 실패: \(error)")
        }
    }
    
    
}
