//
//  TransactionEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import SwiftUI

class TransactionEditor: ObservableObject {
    @Published var isExpense: Bool = true
    @Published var selectedCategory: TransactionCategory?
    @Published var givenAmount: Double
    @Published var description: String = ""
    @Published var selectedDate: Date = Date.now
    @Published var navigationFormTitle: LocalizedStringKey
    var transaction: Transaction?
    
    var isValid: Bool {
        givenAmount != 0 && givenAmount != 0
    }
    
    init(transaction: Transaction? = nil) {
        self.isExpense = transaction?.isExpense ?? true
        self.selectedCategory = transaction?.category ?? nil
        self.givenAmount = transaction?.amount ?? 0
        self.description = transaction?.text ?? ""
        self.transaction = transaction
        self.selectedDate = transaction?.date ?? Date.now
        self.navigationFormTitle = (transaction != nil) ? "Edit transaction" : "New transaction"
    }
    
    // MARK: - Intents
    
    public func save() {
        if let t = transaction {
            TransactionStorage.main.update(t, editor: self)
        } else {
            TransactionStorage.main.add(text: description, isExpense: isExpense, amount: givenAmount, category: selectedCategory)
        }
    }
}
