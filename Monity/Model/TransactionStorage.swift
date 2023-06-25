//
//  TransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import CoreData
import Combine

class TransactionFetchController: CoreDataModelStorage<Transaction> {
    public static let all = TransactionFetchController()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ])
    }
    
//    init(month: Int, year: Int) {
//        super.init(sortDescriptors: [
//            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
//        ], keyPathsForRefreshing: [
//            #keyPath(Transaction.category.name)
//        ])
//    }
    
}

class TransactionStorage {
    static func add(set rows: [String]) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? context.fetch(categoriesFetchRequest)
        guard let transactionCategories = currentCategories else {
            return false
        }
        var categories = transactionCategories
        for row in rows {
            let rowContents = Utils.separateCSVRow(row)
            let description: String = rowContents[0]
            let amount: Double = Double(rowContents[1]) ?? 0
            let date: Date = Utils.formatFlutterDateStringToDate(rowContents[2])
            let isExpense: Bool = rowContents[3] == "0" || rowContents[3] == "expense"
            let categoryName: String = rowContents[4]
            var category = categories.first(where: { $0.wrappedName == categoryName })
            if category == nil {
                let newCategory = TransactionCategory(context: context)
                newCategory.name = categoryName
                newCategory.id = UUID()
                category = newCategory
                categories.append(newCategory)
            }
            let _ = add(text: description, isExpense: isExpense, amount: amount, category: category, date: date, saveContext: false)
        }
        try? context.save()
        return true
    }
    
    static func add(text: String, isExpense: Bool, amount: Double, category: TransactionCategory?, date: Date = Date(), saveContext: Bool = true) {
        let context = PersistenceController.shared.container.viewContext
        context.performAndWait {
            let transaction = Transaction(context: context)
            transaction.id = UUID()
            transaction.date = date
            transaction.isExpense = isExpense
            transaction.amount = amount
            transaction.category = category
            transaction.text = text
            if saveContext {
                try? context.save()
            }
        }
    }
    
    static func update(_ transaction: Transaction, editor: TransactionEditor) {
        let context = PersistenceController.shared.container.viewContext
        context.performAndWait {
            transaction.text = editor.description
            transaction.category = editor.selectedCategory
            transaction.isExpense = editor.isExpense
            transaction.amount = editor.givenAmount
            transaction.date = editor.selectedDate
            try? context.save()
        }
    }

    static func delete(_ transaction: Transaction) {
        let context = PersistenceController.shared.container.viewContext
        context.performAndWait {
            context.delete(transaction)
            do {
                try context.save()
            } catch {
                context.rollback()
                print("Failed to save context \(error.localizedDescription)")
            }
        }
    }
    
    static func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try PersistenceController.shared.container.viewContext.executeAndMergeChanges(using: deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
}
