//
//  SavingsCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation

class SavingsCategoryFetchController: BaseFetchController<SavingsCategory> {
    static let all: SavingsCategoryFetchController = SavingsCategoryFetchController()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \SavingsCategory.name, ascending: true)
        ], keyPathsForRefreshing: [#keyPath(SavingsCategory.entries)])
    }
}

class SavingsCategoryStorage: ResettableStorage<SavingsCategory> {
    static let main: SavingsCategoryStorage = SavingsCategoryStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    func add(name: String, label: SavingsCategoryLabel) -> SavingsCategory {
        let category = SavingsCategory(context: self.context)
        category.id = UUID()
        category.name = name
        category.label = label.rawValue
        category.isHidden = false
        category.entries = []
        try? self.context.save()
        return category
    }
    
    func addIfNotExisting(set savingsCategories: [String]) -> Bool {
        let categoriesFetchRequest = SavingsCategory.fetchRequest()
        let currentCategories: [SavingsCategory]? = try? self.context.fetch(categoriesFetchRequest)
        guard let existingSavingsCategories = currentCategories else {
            return false
        }
        
        for category in savingsCategories {
            if existingSavingsCategories.contains(where: { tmpCategory in
                tmpCategory.wrappedName == category
            }) {
                continue
            }
            let newCategory = SavingsCategory(context: self.context)
            newCategory.name = category
            newCategory.id = UUID()
            newCategory.isHidden = false
        }
        try? self.context.save()
        return true
    }
    
    func update(_ category: SavingsCategory, name: String? = nil, label: SavingsCategoryLabel? = nil, isHidden: Bool? = nil) -> Bool {
        self.context.performAndWait {
            category.name = name ?? category.name
            category.label = label?.rawValue ?? category.label
            category.isHidden = isHidden ?? category.isHidden
            if let _ = try? self.context.save() {
                return true
            } else {
                return false
            }
        }
    }
}
