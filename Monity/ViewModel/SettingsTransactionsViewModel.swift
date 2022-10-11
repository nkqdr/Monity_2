//
//  SettingsTransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine

class SettingsTransactionsViewModel: ObservableObject {
    @Published var monthlyLimit: Double = UserDefaults.standard.double(forKey: "monthly_limit")
    @Published var categories: [TransactionCategory] = []
    @Published var currentCategory: TransactionCategory? = nil
    
    private var categoryCancellable: AnyCancellable?
    
    init(categoryPublisher: AnyPublisher<[TransactionCategory], Never> = TransactionCategoryStorage.shared.categories.eraseToAnyPublisher()) {
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
    
    // MARK: - Intents
    
    func deleteCategory(_ category: TransactionCategory) {
        TransactionCategoryStorage.shared.delete(category)
    }
}
