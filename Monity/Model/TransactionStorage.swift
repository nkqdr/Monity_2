//
//  TransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import CoreData

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
    init(start: Date, end: Date) {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ], keyPathsForRefreshing: [
            #keyPath(Transaction.category.name)
        ], predicate: NSPredicate(format: "date >= %@ && date <= %@", start as NSDate, end as NSDate))
    }
}

class TransactionStorage {
    public static let main = TransactionStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    private let context: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.context = managedObjectContext
    }
    
    func add(set rows: [String]) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? self.context.fetch(categoriesFetchRequest)
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
                let newCategory = TransactionCategory(context: self.context)
                newCategory.name = categoryName
                newCategory.id = UUID()
                category = newCategory
                categories.append(newCategory)
            }
            let _ = add(text: description, isExpense: isExpense, amount: amount, category: category, date: date, saveContext: false)
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
            transaction.amount = editor.givenAmount
            transaction.date = editor.selectedDate
            try? self.context.save()
        }
    }

    func delete(_ transaction: Transaction) {
        self.context.performAndWait {
            context.delete(transaction)
            do {
                try self.context.save()
            } catch {
                self.context.rollback()
                print("Failed to save context \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        self.context.performAndWait {
            do {
                try self.context.executeAndMergeChanges(using: deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}
