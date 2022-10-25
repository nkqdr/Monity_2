//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine

class SavingsViewModel: ItemListViewModel<SavingsCategory> {
    init() {
        let categoryPublisher = SavingsCategoryStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: categoryPublisher)
    }
}
