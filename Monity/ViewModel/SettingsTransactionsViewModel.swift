//
//  SettingsTransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine

class SettingsTransactionsViewModel: ItemListViewModel<TransactionCategory> {
    @Published var monthlyLimit: Double = UserDefaults.standard.double(forKey: AppStorageKeys.monthlyLimit)
    
    init() {
        let publisher = TransactionCategoryStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    // MARK: - Intents
    
    override func deleteItem(_ item: TransactionCategory) {
        TransactionCategoryStorage.shared.delete(item)
    }
}
