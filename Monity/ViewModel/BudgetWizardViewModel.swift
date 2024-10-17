//
//  BudgetWizardViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 13.07.24.
//

import Foundation
import Combine
import Accelerate

class CategoryBudgetMap: ObservableObject, Identifiable {
    var category: TransactionCategory
    @Published var budget: Double
    @Published var hasBudget: Bool {
        willSet {
            self.budget = 0
        }
    }
    var lastSavedBudget: Budget?
    var id: UUID {
        category.id ?? UUID()
    }
    
    init(category: TransactionCategory) {
        self.category = category
        self.lastSavedBudget = category.lastSavedBudget
        if let savedBudget = self.lastSavedBudget, savedBudget.amount != 0 {
            self.budget = savedBudget.amount
            self.hasBudget = true
        } else {
            self.budget = 0
            self.hasBudget = false
        }
    }
}

class BudgetWizardViewModel: ObservableObject {
    @Published var budgetMaps: [CategoryBudgetMap] = []
    @Published var tmpMonthlyBudget: Double
    @Published var showWarning: Bool = false
    @Published var categoryBudgetSum: Double = 0
    
    private var lastKnownBudget: Budget?
    private var budgetMapCancellables: [AnyCancellable?] = []
    private var fetchController: TransactionCategoryFetchController
    private var persistenceController: PersistenceController
    
    init(
        controller: PersistenceController = PersistenceController.shared
    ) {
        let budgetResults = MonthlyBudgetFetchController().items.value
        let lastKnownBudget = budgetResults.first
        self.lastKnownBudget = lastKnownBudget
        self.tmpMonthlyBudget = lastKnownBudget?.amount ?? 0
        self.persistenceController = controller
        self.fetchController = TransactionCategoryFetchController(managedObjectContext: controller.managedObjectContext)
        let allCategories = fetchController.items.value
        self.budgetMaps = allCategories.map { CategoryBudgetMap(category: $0) }
        self.categoryBudgetSum = vDSP.sum(self.budgetMaps.map { $0.budget })
        self.budgetMapCancellables = self.budgetMaps.map {
            $0.objectWillChange.receive(on: RunLoop.main).sink {
                self.categoryBudgetSum = vDSP.sum(self.budgetMaps.map { $0.budget })
            }
        }
    }
    
    private func performSave() {
        let storage = BudgetStorage(
            managedObjectContext: self.persistenceController.managedObjectContext
        )
        let lastIndex = budgetMaps.count - 1
        for (idx, budgetDef) in budgetMaps.enumerated() {
            if let saved = budgetDef.lastSavedBudget, saved.amount == budgetDef.budget {
                // Do not store the same saved budget twice
                continue
            }
            print("Saving \(budgetDef.category.wrappedName) -> \(budgetDef.budget), \(budgetDef.hasBudget)")
            let _ = storage.add(
                amount: budgetDef.budget,
                category: budgetDef.category,
                save: idx == lastIndex
            )
        }
        if let lastBudget = self.lastKnownBudget, lastBudget.amount == self.tmpMonthlyBudget {
            return
        }
        let _ = storage.add(amount: tmpMonthlyBudget, category: nil)
    }
    
    public func save(force: Bool = false, callback: () -> Void) {
        self.categoryBudgetSum = vDSP.sum(budgetMaps.map { $0.budget })
        if self.categoryBudgetSum != self.tmpMonthlyBudget && !force {
            self.showWarning = true
            return
        }
        performSave()
        callback()
    }
}
