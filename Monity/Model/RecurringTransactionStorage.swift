//
//  RecurringTransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation

class RecurringTransactionStorage: CoreDataModelStorage<RecurringTransaction> {
    static let shared: RecurringTransactionStorage = RecurringTransactionStorage()
    
    private init() {
        super.init(sortDescriptors: [
            NSSortDescriptor(keyPath: \RecurringTransaction.name, ascending: true)
        ])
    }
    
    func add(name: String, amount: Double, startDate: Date, endDate: Date?, cycle: TransactionCycle, isDeducted: Bool) -> RecurringTransaction {
        let transaction = RecurringTransaction(context: PersistenceController.shared.container.viewContext)
        transaction.name = name
        transaction.amount = amount
        transaction.startDate = startDate
        transaction.endDate = endDate
        transaction.cycle = cycle.rawValue
        transaction.isDeducted = isDeducted
        transaction.id = UUID()
        try? PersistenceController.shared.container.viewContext.save()
        return transaction
    }
    
    func update(_ transaction: RecurringTransaction, editor: RecurringTransactionEditor) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            transaction.name = editor.name
            transaction.amount = editor.amount
            transaction.startDate = editor.startDate
            transaction.endDate = editor.isStillActive ? nil : editor.endDate
            transaction.cycle = editor.cycle.rawValue
            transaction.isDeducted = editor.isDeducted
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
