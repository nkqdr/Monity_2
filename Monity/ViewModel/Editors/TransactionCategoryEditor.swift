//
//  TransactionCategoryEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import SwiftUI

class TransactionCategoryEditor: ObservableObject {
    @Published var name: String {
        didSet {
            disableSave = allCategories.map { $0.wrappedName }.contains(name) || name == ""
        }
    }
    @Published var disableSave: Bool = true
    @Published var selectedIcon: String?
    @Published var budgetAmount: Double
    private var allCategories: [TransactionCategory]
    var category: TransactionCategory?
    
    var isValid: Bool {
        let nameIsValid: Bool = self.name != ""
        let nameIsDirty: Bool = category == nil ? true : category?.wrappedName != self.name
        let iconIsDirty: Bool = category == nil ? true : category?.iconName != self.selectedIcon
        let budgetIsDirty: Bool = budgetAmount != category?.lastSavedBudget?.amount
        
        return nameIsValid && (nameIsDirty || iconIsDirty || budgetIsDirty)
    }
    
    init(category: TransactionCategory? = nil) {
        self.name = category?.wrappedName ?? ""
        self.category = category
        self.selectedIcon = category?.iconName
        let fetchRequest = TransactionCategory.fetchRequest()
        let categories = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        self.allCategories = categories ?? []
        self.budgetAmount = category?.lastSavedBudget?.amount ?? 0
    }
    
    private func trySaveBudget(for category: TransactionCategory) {
        if self.budgetAmount != category.lastSavedBudget?.amount {
            let _ = BudgetStorage.main.add(amount: self.budgetAmount, category: category)
        }
    }
    
    // MARK: - Intent
    
    public func save() -> TransactionCategory {
        if let c = category {
            trySaveBudget(for: c)
            return TransactionCategoryStorage.main.update(c, name: name, iconName: selectedIcon)
        } else {
            let category = TransactionCategoryStorage.main.add(name: name, iconName: selectedIcon)
            print("Added category \(category.wrappedName)")
            trySaveBudget(for: category)
            return category
        }
    }
}
