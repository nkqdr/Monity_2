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
    static let all = TransactionFetchController()
    static let currentMonth = TransactionFetchController.generateCurrentMonth()
    
    private static func generateCurrentMonth() -> TransactionFetchController {
        let comps = Calendar.current.dateComponents([.month, .year], from: Date())
        return TransactionFetchController(month: comps.month, year: comps.year)
    }
    
    /// This initializer will create a FetchedResultsController for all transactions.
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ])
    }
    
    /// This initializer will create a FetchedResultsController for all transactions in the given month.
    init(month: Int?, year: Int?) {
        let date: Date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        let startOfMonth: Date = date.startOfThisMonth.removeTimeStamp!
        let endOfMonth: Date = Calendar.current.date(byAdding: DateComponents(month: 1), to: startOfMonth) ?? date
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ], predicate: NSPredicate(format: "date >= %@ && date < %@", startOfMonth as NSDate, endOfMonth as NSDate))
    }
    
    /// This initializer will create a FetchedResultsController for all transactions in the given timeframe.
    init(startComps: DateComponents, endComps: DateComponents) {
        let startDate = Calendar.current.date(from: startComps) ?? Date()
        let endDate = Calendar.current.date(from: endComps) ?? Date()
        
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ], predicate: NSPredicate(format: "date >= %@ && date <= %@", startDate as NSDate, endDate as NSDate))
    }
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
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        context.performAndWait {
            do {
                try context.executeAndMergeChanges(using: deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}
