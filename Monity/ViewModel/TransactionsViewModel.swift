//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var currentTransaction: Transaction? = nil
    @Published var filteredSelectedDate = Calendar.current.dateComponents([.month, .year], from: Date()) {
        didSet {
            print("Now filtering transactions...")
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    // MARK: - Intents
    
    func deleteTransaction(_ transaction: Transaction) {
        TransactionStorage.shared.delete(transaction)
    }
}
