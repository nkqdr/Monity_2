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
        didSet {
            self.budget = 0
        }
    }
    var lastSavedBudget: Budget?
    var id: UUID {
        category.id ?? UUID()
    }
    
    init(category: TransactionCategory) {
        self.category = category
        self.lastSavedBudget = category.budgetsArray.sorted {
            $0.wrappedValidFrom > $1.wrappedValidFrom
        }.first
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
    @Published var allCategories: [TransactionCategory] = []
    @Published var budgetMaps: [CategoryBudgetMap] = []
    @Published var tmpMonthlyBudget: Double = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
    
    private var categoryCancellable: AnyCancellable?
    private var fetchController: TransactionCategoryFetchController
    private var persistenceController: PersistenceController
    
    init(
        controller: PersistenceController = PersistenceController.shared
    ) {
        self.persistenceController = controller
        self.fetchController = TransactionCategoryFetchController(managedObjectContext: controller.managedObjectContext)
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        self.categoryCancellable = publisher.sink { categories in
            self.allCategories = categories
            self.budgetMaps = categories.map { CategoryBudgetMap(category: $0) }
        }
    }
    
    public func save(callback: () -> Void) {
        let storage = BudgetStorage(
            managedObjectContext: self.persistenceController.managedObjectContext
        )
        let lastIndex = budgetMaps.count - 1
        for (idx, budgetDef) in budgetMaps.enumerated() {
            if let saved = budgetDef.lastSavedBudget, saved.amount == budgetDef.budget {
                // Do not store the same saved budget twice
                continue
            }
            print("\(budgetDef.budget), \(budgetDef.hasBudget)")
            let _ = storage.add(
                amount: budgetDef.budget,
                category: budgetDef.category,
                save: idx == lastIndex
            )
        }
        
        callback()
    }
}
