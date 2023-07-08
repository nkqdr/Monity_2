//
//  RecurringTransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation

class RecurringTransactionFetchController: CoreDataModelStorage<RecurringTransaction> {
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

class RecurringTransactionStorage: CoreDataModelStorage<RecurringTransaction> {
    static let shared: RecurringTransactionStorage = RecurringTransactionStorage()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)
        ])
    }
    
    func add(name: String, category: TransactionCategory?, amount: Double, startDate: Date, endDate: Date?, cycle: TransactionCycle, isDeducted: Bool) -> RecurringTransaction {
        let transaction = RecurringTransaction(context: PersistenceController.shared.container.viewContext)
        transaction.name = name
        transaction.amount = amount
        transaction.startDate = startDate.removeTimeStamp
        transaction.endDate = endDate?.removeTimeStamp
        transaction.cycle = cycle.rawValue
        transaction.isDeducted = isDeducted
        transaction.id = UUID()
        transaction.category = category
        try? PersistenceController.shared.container.viewContext.save()
        return transaction
    }
    
    func update(_ transaction: RecurringTransaction, editor: RecurringTransactionEditor) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            transaction.name = editor.name
            transaction.amount = editor.amount
            transaction.startDate = editor.startDate.removeTimeStamp
            transaction.endDate = editor.isStillActive ? nil : editor.endDate.removeTimeStamp
            transaction.cycle = editor.cycle.rawValue
            transaction.isDeducted = editor.isDeducted
            transaction.category = editor.category
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }
    
    func delete(_ transaction: RecurringTransaction) {
        PersistenceController.shared.container.viewContext.delete(transaction)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
