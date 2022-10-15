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
    
    func add(set rows: [String]) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? PersistenceController.shared.container.viewContext.fetch(categoriesFetchRequest)
        guard let transactionCategories = currentCategories else {
            return false
        }
        var categories = transactionCategories
        for row in rows {
            let rowContents = Utils.separateCSVRow(row)
            let description: String = rowContents[0]
            let amount: Double = Double(rowContents[1]) ?? 0
            let date: Date = Utils.formatFlutterDateStringToDate(rowContents[2])
            let isExpense: Bool = rowContents[3] == "0"
            let categoryName: String = rowContents[4]
            var category = categories.first(where: { $0.wrappedName == categoryName })
            if category == nil {
                let newCategory = TransactionCategory(context: PersistenceController.shared.container.viewContext)
                newCategory.name = categoryName
                newCategory.id = UUID()
                category = newCategory
                categories.append(newCategory)
            }
            let _ = add(text: description, isExpense: isExpense, amount: amount, category: category, date: date, saveContext: false)
        }
        try? PersistenceController.shared.container.viewContext.save()
        return true
    }
    
    func add(text: String, isExpense: Bool, amount: Double, category: TransactionCategory?, date: Date = Date(), saveContext: Bool = true) -> Transaction {
        let transaction = Transaction(context: PersistenceController.shared.container.viewContext)
        transaction.id = UUID()
        transaction.date = date
        transaction.isExpense = isExpense
        transaction.amount = amount
        transaction.category = category
        transaction.text = text
        if saveContext {
            try? PersistenceController.shared.container.viewContext.save()
        }
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
