//
//  TransactionEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine

class TransactionEditor: ObservableObject {
    @Published var isExpense: Bool = true
    @Published var selectedCategory: TransactionCategory?
    @Published var givenAmount: Double = 0
    @Published var description: String = ""
    @Published var selectedDate: Date = Date.now
    @Published var categories: [TransactionCategory] = []
    @Published var navigationFormTitle: String
    var transaction: Transaction?
    
    private var categoryCancellable: AnyCancellable?
    
    init(transaction: Transaction? = nil) {
        let categoryPublisher = TransactionCategoryStorage.shared.items.eraseToAnyPublisher()
        self.isExpense = transaction?.isExpense ?? true
        self.selectedCategory = transaction?.category ?? nil
        self.givenAmount = transaction?.amount ?? 0
        self.description = transaction?.text ?? ""
        self.transaction = transaction
        self.selectedDate = transaction?.date ?? Date.now
        self.navigationFormTitle = (transaction != nil) ? "Edit transaction" : "New transaction"
        
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
    
    // MARK: - Intents
    
    public func save() {
        if let t = transaction {
            let _ = TransactionStorage.shared.update(t, editor: self)
        } else {
            let _ = TransactionStorage.shared.add(text: description, isExpense: isExpense, amount: givenAmount, category: selectedCategory)
        }
    }
}
