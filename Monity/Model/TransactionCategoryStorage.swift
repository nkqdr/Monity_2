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

class TransactionCategoryStorage: ResettableStorage<TransactionCategory> {
    static let main: TransactionCategoryStorage = TransactionCategoryStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
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
}
