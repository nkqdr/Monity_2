//
//  SettingsSavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine

class SettingsSavingsViewModel: ObservableObject {
    @Published var categories: [SavingsCategory] = []
    @Published var currentCategory: SavingsCategory? = nil
    
    private var categoryCancellable: AnyCancellable?
    
    init() {
        let categoryPublisher = SavingsCategoryStorage.shared.categories.eraseToAnyPublisher()
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
    
    // MARK: - Intents
    func deleteCategory(_ category: SavingsCategory) {
        SavingsCategoryStorage.shared.delete(category)
    }
}
