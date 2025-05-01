//
//  SavingStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import CoreData

class SavingsFetchController: BaseFetchController<SavingsEntry> {
    static let all: SavingsFetchController = SavingsFetchController()
    
    private init(managedObjectContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)],
            managedObjectContext: managedObjectContext
        )
    }
    
    init(
        since: Date? = nil,
        category: SavingsCategory? = nil,
        managedObjectContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        var predicate: NSPredicate = NSPredicate(value: true) // Initialize with an empty predicate
        if let since {
            let sincePredicate = NSPredicate(format: "date >= %@", since as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sincePredicate])
        }
        if let category {
            let categoryPredicate = NSPredicate(format: "category == %@", category)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        }
        super.init(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)
            ],
            predicate: predicate,
            managedObjectContext: managedObjectContext
        )
    }
    
    init(category: SavingsCategory, managedObjectContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        super.init(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)
            ],
            predicate: NSPredicate(format: "category == %@", category),
            managedObjectContext: managedObjectContext
        )
    }
}

class SavingStorage: ResettableStorage<SavingsEntry> {
    static let main: SavingStorage = SavingStorage(managedObjectContext: PersistenceController.shared.container.viewContext)

    override func add(set rows: any Sequence<String>) -> Bool {
        let categoriesFetchRequest = SavingsCategory.fetchRequest()
        let savingsCategories: [SavingsCategory]? = try? self.context.fetch(categoriesFetchRequest)
        
        guard let savingsCategories else { return false }
        return self.context.performAndWait {
            var categories = savingsCategories
            for row in rows {
                let csvObj = SavingsEntry.decodeFromCSV(csvRow: row)
                var category = categories.first(where: { $0.wrappedName == csvObj.categoryName })
                if category == nil {
                    let newCategory = SavingsCategory(context: self.context)
                    newCategory.id = UUID()
                    newCategory.name = csvObj.categoryName
                    newCategory.label = csvObj.categoryLabel.rawValue
                    category = newCategory
                    categories.append(newCategory)
                }
                let _ = add(amount: csvObj.amount, category: category, date: csvObj.date, saveContext: false)
            }
            try? self.context.save()
            return true
        }
    }
    
    func add(amount: Double, category: SavingsCategory?, date: Date = Date(), saveContext: Bool = true) -> SavingsEntry {
        self.context.performAndWait {
            let entry = SavingsEntry(context: self.context)
            entry.id = UUID()
            entry.date = date
            entry.amount = amount
            entry.category = category
            if saveContext {
                try? self.context.save()
            }
            return entry
        }
    }
    
    func update(_ entry: SavingsEntry, editor: SavingsEditor) -> Bool {
        self.context.performAndWait {
            guard let category = editor.category else { return false }
            entry.amount = editor.amount
            entry.category = category
            entry.date = editor.timestamp
            if let _ = try? self.context.save() {
                return true
            } else {
                return false
            }
        }
    }
}
