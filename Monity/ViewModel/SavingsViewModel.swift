//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine

class SavingsViewModel: ObservableObject {
    @Published var categories: [SavingsCategory] = []
    
    private var categoryCancellable: AnyCancellable?
    
    init() {
        let categoryPublisher = SavingsCategoryStorage.shared.categories.eraseToAnyPublisher()
        categoryCancellable = categoryPublisher.sink { categories in
            self.categories = categories
        }
    }
}
