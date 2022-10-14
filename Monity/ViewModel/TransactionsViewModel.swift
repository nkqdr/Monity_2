//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = [] {
        didSet {
            filterTransactionList()
        }
    }
    @Published var filteredTransactions: [Transaction]?
    @Published var currentTransaction: Transaction? = nil
    @Published var filteredSelectedDate = Calendar.current.dateComponents([.month, .year], from: Date()) {
        didSet {
            filterTransactionList()
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    // MARK: - Helper functions
    private func filterTransactionList() {
        filteredTransactions = transactions.filter { transaction in
            let comps = Calendar.current.dateComponents([.month, .year], from: transaction.date ?? Date())
            return comps.month == filteredSelectedDate.month && comps.year == filteredSelectedDate.year
        }
    }
    
    // MARK: - Intents
    
    func deleteTransaction(_ transaction: Transaction) {
        TransactionStorage.shared.delete(transaction)
    }
}
