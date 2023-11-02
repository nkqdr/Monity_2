//
//  TransactionCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import CoreData

class TransactionCategoryFetchController: BaseFetchController<TransactionCategory> {
    static let all = TransactionCategoryFetchController()
    
    private init() {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
        )
    }
}

class TransactionCategoryStorage: ResettableStorage<TransactionCategory> {
    static let main: TransactionCategoryStorage = TransactionCategoryStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    func add(name: String, iconName: String?) -> TransactionCategory {
        let category = TransactionCategory(context: self.context)
        category.name = name
        category.iconName = iconName
        category.id = UUID()
        try? self.context.save()
        return category
    }
    
    func addIfNotExisting(set transactionCategories: [String]) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? self.context.fetch(categoriesFetchRequest)
        guard let existingTransactionCategories = currentCategories else {
            return false
        }
        
        for category in transactionCategories {
            if existingTransactionCategories.contains(where: { tmpCategory in
                tmpCategory.wrappedName == category
            }) {
                continue
            }
            let newCategory = TransactionCategory(context: self.context)
            newCategory.name = category
            newCategory.id = UUID()
        }
        try? self.context.save()
        return true
    }
    
    func update(_ category: TransactionCategory, name: String?, iconName: String?) -> Bool {
        self.context.performAndWait {
            category.name = name ?? category.name
            category.iconName = iconName
            if let _ = try? self.context.save() {
                return true
            } else {
                return false
            }
        }
    }
}
