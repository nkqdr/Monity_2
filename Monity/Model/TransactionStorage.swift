//
//  TransactionStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine
import CoreData

class TransactionStorage: NSObject, ObservableObject {
    var transactions = CurrentValueSubject<[Transaction], Never>([])
    private let transactionsFetchController: RichFetchedResultsController<Transaction>
    
    static let shared: TransactionStorage = TransactionStorage()
    
    private override init() {
        let request = RichFetchRequest<Transaction>(entityName: "Transaction")
//        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        request.relationshipKeyPathsForRefreshing = [
            #keyPath(Transaction.category.name)
        ]
        transactionsFetchController = RichFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        transactionsFetchController.delegate = self
        do {
            try transactionsFetchController.performFetch()
            transactions.value = transactionsFetchController.fetchedObjects! as? [Transaction] ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func add(text: String, isExpense: Bool, amount: Double, category: TransactionCategory?) -> Transaction {
        let transaction = Transaction(context: PersistenceController.shared.container.viewContext)
        transaction.id = UUID()
        transaction.date = Date.now
        transaction.isExpense = isExpense
        transaction.amount = amount
        transaction.category = category
        transaction.text = text
        try? PersistenceController.shared.container.viewContext.save()
        return transaction
    }
    
    func update(_ transaction: Transaction, editor: TransactionEditor) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            transaction.text = editor.description
            transaction.category = editor.selectedCategory
            transaction.isExpense = editor.isExpense
            transaction.amount = editor.givenAmount
            transaction.date = editor.selectedDate
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }

    func delete(_ transaction: Transaction) {
        PersistenceController.shared.container.viewContext.delete(transaction)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}

extension TransactionStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let transactions = controller.fetchedObjects as? [Transaction] else { return }
        print("Context has changed, reloading transactions")
        self.transactions.value = transactions
    }
}
