//
//  SavingStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation

class SavingStorage: CoreDataModelStorage<SavingsEntry> {
    static let shared: SavingStorage = SavingStorage()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \SavingsEntry.date, ascending: false)
        ])
    }
    
    func add(set rows: [String]) -> Bool {
        let categoriesFetchRequest = SavingsCategory.fetchRequest()
        let savingsCategories: [SavingsCategory]? = try? PersistenceController.shared.container.viewContext.fetch(categoriesFetchRequest)
        
        guard let savingsCategories else { return false }
        var categories = savingsCategories
        for row in rows {
            let rowContents = Utils.separateCSVRow(row)
            let amount: Double = Double(rowContents[0]) ?? 0
            let date: Date = Utils.formatFlutterDateStringToDate(rowContents[1])
            let categoryName: String = rowContents[2]
            let categoryLabel: SavingsCategoryLabel = SavingsCategoryLabel.by(rowContents[3])
            var category = categories.first(where: { $0.wrappedName == categoryName })
            if category == nil {
                let newCategory = SavingsCategory(context: PersistenceController.shared.container.viewContext)
                newCategory.id = UUID()
                newCategory.name = categoryName
                newCategory.label = categoryLabel.rawValue
                category = newCategory
                categories.append(newCategory)
            }
            let _ = add(amount: amount, category: category, date: date, saveContext: false)
        }
        try? PersistenceController.shared.container.viewContext.save()
        return true
    }
    
    func add(amount: Double, category: SavingsCategory?, date: Date = Date(), saveContext: Bool = true) -> SavingsEntry {
        let entry = SavingsEntry(context: PersistenceController.shared.container.viewContext)
        entry.id = UUID()
        entry.date = date
        entry.amount = amount
        entry.category = category
        if saveContext {
            try? PersistenceController.shared.container.viewContext.save()
        }
        return entry
    }
    
    func update(_ entry: SavingsEntry, editor: SavingsEditor) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            guard let category = editor.category else { return false }
            entry.amount = editor.amount
            entry.category = category
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }

    func delete(_ entry: SavingsEntry) {
        PersistenceController.shared.container.viewContext.delete(entry)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
