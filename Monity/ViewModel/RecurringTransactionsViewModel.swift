//
//  RecurringTransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation

class RecurringTransactionsViewModel: ItemListViewModel<RecurringTransaction> {
    public static let shared = RecurringTransactionsViewModel()
    
    private init() {
        let publisher = RecurringTransactionStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    // MARK: - Intent
    
    override func deleteItem(_ item: RecurringTransaction) {
        RecurringTransactionStorage.shared.delete(item)
    }
}
