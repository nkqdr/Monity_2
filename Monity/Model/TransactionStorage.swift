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
    
    /// This initializer will create a FetchedResultsController for all transactions.
    private init(
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ],
        keyPathsForRefreshing: Set<String> = [
            #keyPath(Transaction.category.name),
            #keyPath(Transaction.category.iconName)
        ],
        predicate: NSPredicate?,
        controller: PersistenceController = PersistenceController.shared
    ) {
        super.init(sortDescriptors: sortDescriptors, keyPathsForRefreshing: keyPathsForRefreshing, predicate: predicate, managedObjectContext: controller.managedObjectContext)
    }
    
    /// This initializer will create a FetchedResultsController for all transactions in the given month.
    convenience init(month: Int?, year: Int?) {
        let date: Date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        let startOfMonth: Date = date.startOfThisMonth.removeTimeStamp!
        let endOfMonth: Date = Calendar.current.date(byAdding: DateComponents(month: 1), to: startOfMonth) ?? date

        self.init(predicate: NSPredicate(format: "date >= %@ && date < %@", startOfMonth as NSDate, endOfMonth as NSDate))
    }
    
    /// This initializer will create a FetchedResultsController for all transactions in the given timeframe.
    convenience init(
        start: Date,
        end: Date? = nil,
        category: TransactionCategory? = nil,
        controller: PersistenceController = PersistenceController.shared
    ) {
        var finalPredicate: NSPredicate
        var datePredicate: NSPredicate = NSPredicate(format: "date >= %@", start as NSDate)
        if let end {
            let beforeEndPredicate = NSPredicate(format: "date <= %@", end as NSDate)
            datePredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [datePredicate, beforeEndPredicate]
            )
        }
        finalPredicate = datePredicate
        if let category {
            let categoryPredicate = NSPredicate(format: "category == %@", category)
            finalPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [finalPredicate, categoryPredicate]
            )
        }
        
        self.init(predicate: finalPredicate, controller: controller)
    }
    
    /// This initializer will create a FetchedResultsController for all transactions with the given category
    convenience init(
        category: TransactionCategory? = nil,
        isExpense: Bool? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        controller: PersistenceController = PersistenceController.shared
    ) {
        var finalPredicate = NSPredicate(value: true)
        if let category {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                finalPredicate, NSPredicate(format: "category == %@", category)
            ])
        }
        if let isExpense {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                finalPredicate, NSPredicate(format: "isExpense == %@", NSNumber(booleanLiteral: isExpense))
            ])
        }
        if let startDate {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                finalPredicate, NSPredicate(format: "date >= %@", startDate as NSDate)
            ])
        }
        if let endDate {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                finalPredicate, NSPredicate(format: "date < %@", endDate as NSDate)
            ])
        }
        self.init(predicate: finalPredicate, controller: controller)
    }
}

class TransactionStorage: ResettableStorage<Transaction> {
    public static let main = TransactionStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    override func add(set rows: any Sequence<String>) -> Bool {
        let categoriesFetchRequest = TransactionCategory.fetchRequest()
        let currentCategories: [TransactionCategory]? = try? self.context.fetch(categoriesFetchRequest)
        guard let transactionCategories = currentCategories else {
            return false
        }
        return self.context.performAndWait {
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
}
