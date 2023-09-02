//
//  SavingStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation

class SavingsFetchController: BaseFetchController<SavingsEntry> {
    static let all: SavingsFetchController = SavingsFetchController()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)
        ])
    }
    
    init(since: Date) {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)
        ], predicate: NSPredicate(format: "date >= %@", since as NSDate))
    }
}

class SavingStorage: ResettableStorage<SavingsEntry> {
    static let main: SavingStorage = SavingStorage(managedObjectContext: PersistenceController.shared.container.viewContext)

    func add(set rows: [String]) -> Bool {
        let categoriesFetchRequest = SavingsCategory.fetchRequest()
        let savingsCategories: [SavingsCategory]? = try? self.context.fetch(categoriesFetchRequest)
        
        guard let savingsCategories else { return false }
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
    
    func add(amount: Double, category: SavingsCategory?, date: Date = Date(), saveContext: Bool = true) -> SavingsEntry {
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
