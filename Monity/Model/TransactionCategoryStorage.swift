//
//  TransactionCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import CoreData

class TransactionCategoryFetchController: CoreDataModelStorage<TransactionCategory> {
    static let all = TransactionCategoryFetchController()
    
    private init() {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
        )
    }
}

class TransactionCategoryStorage {
    static let main: TransactionCategoryStorage = TransactionCategoryStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    private let context: NSManagedObjectContext
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.context = managedObjectContext
    }
    
    func add(name: String) -> TransactionCategory {
        let category = TransactionCategory(context: self.context)
        category.name = name
        category.id = UUID()
        try? self.context.save()
        return category
    }
    
    func update(_ category: TransactionCategory, name: String?) -> Bool {
        self.context.performAndWait {
            category.name = name ?? category.name
            if let _ = try? self.context.save() {
                return true
            } else {
                return false
            }
        }
    }
    
    func delete(_ category: TransactionCategory) {
        self.context.delete(category)
        do {
            try self.context.save()
        } catch {
            self.context.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
    func delete(allIn categories: [TransactionCategory]) {
        for category in categories {
            self.context.delete(category)
        }
        do {
            try self.context.save()
        } catch {
            self.context.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TransactionCategory.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        self.context.performAndWait {
            do {
                try self.context.executeAndMergeChanges(using: deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}
