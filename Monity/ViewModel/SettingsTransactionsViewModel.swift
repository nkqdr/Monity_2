//
//  SettingsTransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine

class SettingsTransactionsViewModel: ObservableObject {
    @Published var monthlyLimit: Double = 12.0
    @Published var categories: [TransactionCategory] = []
    
    private var categoryCancellable: AnyCancellable?
    
    init(categoryPublisher: AnyPublisher<[TransactionCategory], Never> = TransactionCategoryStorage.shared.categories.eraseToAnyPublisher()) {
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
}
