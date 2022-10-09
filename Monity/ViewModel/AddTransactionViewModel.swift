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
    @Published var selectedCategory: String?
    @Published var givenAmount: String = ""
    @Published var description: String = ""
    @Published var categories: [TransactionCategory] = []
    
    private var categoryCancellable: AnyCancellable?
    
    init(categoryPublisher: AnyPublisher<[TransactionCategory], Never> = TransactionCategoryStorage.shared.categories.eraseToAnyPublisher()) {
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
}
