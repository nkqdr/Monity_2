//
//  TransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import CoreData

class TransactionFetchController: BaseFetchController<Transaction> {
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
    init(start: Date, end: Date, category: TransactionCategory? = nil) {
        var predicate: NSPredicate
        if let category {
            predicate = NSPredicate(format: "date >= %@ && date <= %@ && category == %@", start as NSDate, end as NSDate, category)
        } else {
            predicate = NSPredicate(format: "date >= %@ && date <= %@", start as NSDate, end as NSDate)
        }
        
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ], predicate: predicate)
    }
    
    /// This initializer will create a FetchedResultsController for all transactions with the given category
    init(category: TransactionCategory, isExpense: Bool) {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ], predicate: NSPredicate(format: "category == %@ && isExpense == %@", category, NSNumber(booleanLiteral: isExpense)))
    }
}

class TransactionStorage: ResettableStorage<Transaction> {
    public static let main = TransactionStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    func add(set rows: [String]) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? self.context.fetch(categoriesFetchRequest)
        guard let transactionCategories = currentCategories else {
            return false
        }
        var categories = transactionCategories
        for row in rows {
            let obj = Transaction.decodeFromCSV(csvRow: row)
            var category = categories.first(where: { $0.wrappedName == obj.categoryName })
            if category == nil, !obj.categoryName.isEmpty {
                let newCategory = TransactionCategory(context: self.context)
                newCategory.name = obj.categoryName
                newCategory.id = UUID()
                category = newCategory
                categories.append(newCategory)
            }
            let _ = add(text: obj.description, isExpense: obj.isExpense, amount: obj.amount, category: category, date: obj.date, saveContext: false)
        }
        try? self.context.save()
        return true
    }
    
    func add(text: String, isExpense: Bool, amount: Double, category: TransactionCategory?, date: Date = Date(), saveContext: Bool = true) {
        self.context.performAndWait {
            let transaction = Transaction(context: context)
            transaction.id = UUID()
            transaction.date = date
            transaction.isExpense = isExpense
            transaction.amount = amount
            transaction.category = category
            transaction.text = text
            if saveContext {
                try? self.context.save()
            }
        }
    }
    
    func update(_ transaction: Transaction, editor: TransactionEditor) {
        self.context.performAndWait {
            transaction.text = editor.description
            transaction.category = editor.selectedCategory
            transaction.isExpense = editor.isExpense
            transaction.amount = editor.givenAmount ?? 0
            transaction.date = editor.selectedDate
            try? self.context.save()
        }
    }
}
