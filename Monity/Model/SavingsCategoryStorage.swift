//
//  SavingsCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation

class SavingsCategoryStorage: CoreDataModelStorage<SavingsCategory> {
    static let shared: SavingsCategoryStorage = SavingsCategoryStorage()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \SavingsCategory.name, ascending: true)
        ])
    }
    
    func add(name: String, label: SavingsCategoryLabel) -> SavingsCategory {
        let category = SavingsCategory(context: PersistenceController.shared.container.viewContext)
        category.id = UUID()
        category.name = name
        category.label = label.rawValue
        category.entries = []
        try? PersistenceController.shared.container.viewContext.save()
        return category
    }
    
    func update(_ category: SavingsCategory, name: String?, label: SavingsCategoryLabel) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            category.name = name ?? category.name
            category.label = label.rawValue
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }
    
    func delete(_ category: SavingsCategory) {
        PersistenceController.shared.container.viewContext.delete(category)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
//    func delete(allIn categories: [TransactionCategory]) {
//        for category in categories {
//            PersistenceController.shared.container.viewContext.delete(category)
//        }
//        do {
//            try PersistenceController.shared.container.viewContext.save()
//        } catch {
//            PersistenceController.shared.container.viewContext.rollback()
//            print("Failed to save context \(error.localizedDescription)")
//        }
//    }
}
