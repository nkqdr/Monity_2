//
//  SettingsSystemViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Combine

class SettingsSystemViewModel: ObservableObject {
    @Published var transactions: [Transaction] = [] {
        didSet {
            registeredTransactions = transactions.count
        }
    }
    @Published var registeredTransactions: Int = 0
    @Published var registeredSavingsEntries: Int = 0
    @Published var storageUsedString: String = PersistenceController.shared.getSqliteStoreSize()
    
    private var transactionCancellable: AnyCancellable?
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
}
