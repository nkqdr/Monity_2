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
    
//    func add(set rows: [String]) -> Bool {
//        let categoriesFetchRequest = TransactionCategory.fetchRequest()
//        let currentCategories: [TransactionCategory]? = try? PersistenceController.shared.container.viewContext.fetch(categoriesFetchRequest)
//        guard let transactionCategories = currentCategories else {
//            return false
//        }
//        var categories = transactionCategories
//        for row in rows {
//            let rowContents = Utils.separateCSVRow(row)
//            let description: String = rowContents[0]
//            let amount: Double = Double(rowContents[1]) ?? 0
//            let date: Date = Utils.formatFlutterDateStringToDate(rowContents[2])
//            let isExpense: Bool = rowContents[3] == "0"
//            let categoryName: String = rowContents[4]
//            var category = categories.first(where: { $0.wrappedName == categoryName })
//            if category == nil {
//                let newCategory = TransactionCategory(context: PersistenceController.shared.container.viewContext)
//                newCategory.name = categoryName
//                newCategory.id = UUID()
//                category = newCategory
//                categories.append(newCategory)
//            }
//            let _ = add(text: description, isExpense: isExpense, amount: amount, category: category, date: date, saveContext: false)
//        }
//        try? PersistenceController.shared.container.viewContext.save()
//        return true
//    }
    
    func add(amount: Double, category: SavingsCategory?, date: Date = Date()) -> SavingsEntry {
        let entry = SavingsEntry(context: PersistenceController.shared.container.viewContext)
        entry.id = UUID()
        entry.date = date
        entry.amount = amount
        entry.category = category
        try? PersistenceController.shared.container.viewContext.save()
        return entry
    }
    
//    func update(_ transaction: Transaction, editor: TransactionEditor) -> Bool {
//        PersistenceController.shared.container.viewContext.performAndWait {
//            transaction.text = editor.description
//            transaction.category = editor.selectedCategory
//            transaction.isExpense = editor.isExpense
//            transaction.amount = editor.givenAmount
//            transaction.date = editor.selectedDate
//            if let _ = try? PersistenceController.shared.container.viewContext.save() {
//                return true
//            } else {
//                return false
//            }
//        }
//    }

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
