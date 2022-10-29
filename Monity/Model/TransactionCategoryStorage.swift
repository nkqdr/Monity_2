//
//  TransactionCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation

class TransactionCategoryStorage: CoreDataModelStorage<TransactionCategory> {
    static let shared: TransactionCategoryStorage = TransactionCategoryStorage()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)
        ])
    }
    
    func add(name: String) -> TransactionCategory {
        let category = TransactionCategory(context: PersistenceController.shared.container.viewContext)
        category.name = name
        category.id = UUID()
        try? PersistenceController.shared.container.viewContext.save()
        return category
    }
    
    func update(_ category: TransactionCategory, name: String?) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            category.name = name ?? category.name
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }
    
    func delete(_ category: TransactionCategory) {
        PersistenceController.shared.container.viewContext.delete(category)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
    func delete(allIn categories: [TransactionCategory]) {
        for category in categories {
            PersistenceController.shared.container.viewContext.delete(category)
        }
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
