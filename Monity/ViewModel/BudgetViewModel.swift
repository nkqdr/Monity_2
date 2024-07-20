//
//  BudgetViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import Foundation
import Combine

class BudgetViewModel: ObservableObject {
    struct DateRangeDataPoint: Identifiable {
        var id = UUID()
        var startDate: Date
        var endDate: Date
        var amount: Double
    }
    @Published var data: [DateRangeDataPoint] = []
    
    private var controller: BudgetFetchController
    private var cancellable: AnyCancellable?
    private var persistenceController: PersistenceController
    
    init(
        for category: TransactionCategory? = nil,
        controller: PersistenceController = PersistenceController.shared
    ) {
        self.persistenceController = controller
        if let category {
            self.controller = BudgetFetchController(
                for: category, managedObjectContext: controller.managedObjectContext
            )
        } else {
            self.controller = MonthlyBudgetFetchController(
                managedObjectContext: controller.managedObjectContext
            )
        }
        let publisher = self.controller.items.eraseToAnyPublisher()
        self.cancellable = publisher.sink { budgets in
            self.calculateDataPoints(for: budgets)
        }
    }
    
    private func calculateDataPoints(for budgets: [Budget]) {
        let ascSortedBudgets = budgets.sorted {
            $0.wrappedValidFrom < $1.wrappedValidFrom
        }
        var data: [DateRangeDataPoint] = []
        let lastIndex = ascSortedBudgets.count - 1
        for (idx, budget) in ascSortedBudgets.enumerated() {
            let validUntil: Date = idx < lastIndex ? ascSortedBudgets[idx + 1].wrappedValidFrom : Date()
            data.append(DateRangeDataPoint(
                startDate: budget.wrappedValidFrom,
                endDate: validUntil,
                amount: budget.amount)
            )
        }
        self.data = data
    }
}
