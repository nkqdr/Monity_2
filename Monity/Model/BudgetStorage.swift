//
//  BudgetStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 10.07.24.
//

import Foundation
import CoreData

class BudgetFetchController: BaseFetchController<Budget> {
    init(
        predicate: NSPredicate? = nil,
        managedObjectContext: NSManagedObjectContext = PersistenceController.shared.managedObjectContext
    ) {
        super.init(
            sortDescriptors: [NSSortDescriptor(keyPath: \Budget.validFrom, ascending: true)],
            predicate: predicate,
            managedObjectContext: managedObjectContext
        )
    }
    
    convenience init(
        for category: TransactionCategory,
        managedObjectContext: NSManagedObjectContext = PersistenceController.shared.managedObjectContext
    ) {
        self.init(
            predicate: NSPredicate(format: "category == %@", category),
            managedObjectContext: managedObjectContext
        )
    }
}

class BudgetStorage: ResettableStorage<Budget> {
    static let main: BudgetStorage = BudgetStorage(
        managedObjectContext: PersistenceController.shared.managedObjectContext
        )
    
    func add(
        amount: Double,
        category: TransactionCategory?,
        validFrom: Date = Date(),
        save: Bool = true
    ) -> Budget {
        self.context.performAndWait {
            let budget = Budget(context: self.context)
            budget.id = UUID()
            budget.validFrom = validFrom
            budget.amount = amount
            budget.category = category
            if save {
                try? self.context.save()
            }
            return budget
        }
    }
}
