//
//  MonthlyBudgetViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import Foundation
import Combine

class MonthlyBudgetViewModel: ObservableObject {
    @Published var currentMonthlyLimit: Double?
    @Published var allMonthlyBudgets: [Budget] = []
    
    private var budgetCancellable: AnyCancellable?
    private var fetchController: MonthlyBudgetFetchController
    private var persistenceController: PersistenceController
    
    init(controller: PersistenceController = PersistenceController.shared) {
        self.persistenceController = controller
        self.fetchController = MonthlyBudgetFetchController(
            managedObjectContext: controller.managedObjectContext
        )
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        self.budgetCancellable = publisher.sink { budgets in
            self.allMonthlyBudgets = budgets
            if let b = budgets.first, b.amount != 0 {
                self.currentMonthlyLimit = b.amount
            } else {
                self.currentMonthlyLimit = nil
            }
        }
    }
    
    public func removeMonthlyBudget() {
        let storage = BudgetStorage(
            managedObjectContext: self.persistenceController.managedObjectContext
        )
        let _ = storage.add(amount: 0, category: nil)
    }
}
