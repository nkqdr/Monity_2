//
//  RecurringTransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation
import CoreData

class RecurringTransactionFetchController: BaseFetchController<RecurringTransaction> {
    public static let all = RecurringTransactionFetchController()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)
        ])
    }
    
    /// FetchController for only those recurring transactions which are active at the given `date`.
    public init(date: Date) {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)],
            predicate: NSPredicate(format: "startDate <= %@  && (endDate == NIL || endDate < %@)", date as NSDate, date as NSDate))
    }
    
    public init(category: TransactionCategory) {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)],
            predicate: NSPredicate(format: "category == %@", category))
    }
    
    /// FetchController for only those recurring transactions which were active somewhere in the given date range.
    public init(startDate: Date, endDate: Date) {
        let hangingLeftPredicate = NSPredicate(format: "startDate <= %@ && endDate >= %@", startDate as NSDate, startDate as NSDate)
        let inBetweenPredicate = NSPredicate(format: "startDate >= %@ && endDate <= %@", startDate as NSDate, endDate as NSDate)
        let hangingRightPredicate = NSPredicate(format: "startDate <= %@ && endDate >= %@", endDate as NSDate, endDate as NSDate)
        let stillGoingPredicate = NSPredicate(format: "endDate == NIL && startDate >= %@ && startDate <= %@", startDate as NSDate, endDate as NSDate)
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)],
            predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [hangingLeftPredicate, inBetweenPredicate, hangingRightPredicate, stillGoingPredicate])
        )
    }
}

class RecurringTransactionStorage: ResettableStorage<RecurringTransaction> {
    static let main: RecurringTransactionStorage = RecurringTransactionStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    override func add(set rows: any Sequence<String>) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? self.context.fetch(categoriesFetchRequest)
        guard let transactionCategories = currentCategories else {
            return false
        }
        return self.context.performAndWait {
            var categories = transactionCategories
            for row in rows {
                let obj = RecurringTransaction.decodeFromCSV(csvRow: row)
                var category = categories.first(where: { $0.wrappedName == obj.categoryName })
                if category == nil, !obj.categoryName.isEmpty {
                    let newCategory = TransactionCategory(context: self.context)
                    newCategory.name = obj.categoryName
                    newCategory.id = UUID()
                    category = newCategory
                    categories.append(newCategory)
                }
                let _ = add(name: obj.name, category: category, amount: obj.amount, startDate: obj.startDate, endDate: obj.endDate, cycle: obj.cycle, isDeducted: true, saveContext: false)
            }
            try? self.context.save()
            return true
        }
    }
    
    func add(name: String, category: TransactionCategory?, amount: Double, startDate: Date, endDate: Date?, cycle: TransactionCycle, isDeducted: Bool, saveContext: Bool = true) -> RecurringTransaction {
        self.context.performAndWait {
            let transaction = RecurringTransaction(context: self.context)
            transaction.name = name
            transaction.amount = amount
            transaction.startDate = startDate.removeTimeStamp
            transaction.endDate = endDate?.removeTimeStamp
            transaction.cycle = cycle.rawValue
            transaction.isDeducted = isDeducted
            transaction.id = UUID()
            transaction.category = category
            if saveContext {
                try? self.context.save()
            }
            return transaction
        }
    }
    
    func update(_ transaction: RecurringTransaction, editor: RecurringTransactionEditor) -> Bool {
        self.context.performAndWait {
            transaction.name = editor.name
            transaction.amount = editor.amount
            transaction.startDate = editor.startDate.removeTimeStamp
            transaction.endDate = editor.isStillActive ? nil : editor.endDate.removeTimeStamp
            transaction.cycle = editor.cycle.rawValue
            transaction.isDeducted = editor.isDeducted
            transaction.category = editor.category
            if let _ = try? self.context.save() {
                return true
            } else {
                return false
            }
        }
    }
}
