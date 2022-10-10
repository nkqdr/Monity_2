//
//  AddTransactionViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine

class AddTransactionViewModel: ObservableObject {
    @Published var isExpense: Bool = true
    @Published var selectedCategory: TransactionCategory?
    @Published var givenAmount: Double = 0
    @Published var description: String = ""
    @Published var categories: [TransactionCategory] = []
    var transaction: Transaction?
    
    private var categoryCancellable: AnyCancellable?
    
    init(transaction: Transaction? = nil, categoryPublisher: AnyPublisher<[TransactionCategory], Never> = TransactionCategoryStorage.shared.categories.eraseToAnyPublisher()) {
        self.isExpense = transaction?.isExpense ?? true
        self.selectedCategory = transaction?.category ?? nil
        self.givenAmount = transaction?.amount ?? 0
        self.description = transaction?.text ?? ""
        self.transaction = transaction
        
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
    
    // MARK: - Intents
    
    public func save() {
        if let _ = transaction {
//            let res = TransactionStorage.shared.update(t, name: name)
//            print(res)
        } else {
            let transaction = TransactionStorage.shared.add(text: description, isExpense: isExpense, amount: givenAmount, category: selectedCategory)
            print("Added transaction \(transaction.description)")
        }
    }
}
