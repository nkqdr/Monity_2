//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    struct TransactionsByDate: Identifiable {
        var id = UUID()
        var date: Date
        var transactions: [Transaction]
    }
    @Published var currentTransactionsByDate: [TransactionsByDate] = []
    @Published var transactions: [Transaction] = [] {
        didSet {
            filterTransactionList()
        }
    }
    @Published var filteredTransactions: [Transaction]? = nil {
        didSet {
            if let filteredTransactions {
                var byDate: [TransactionsByDate] = []
                let uniqueDates = Set(filteredTransactions.map { $0.date?.removeTimeStamp ?? Date() })
                for uniqueDate in uniqueDates {
                    byDate.append(TransactionsByDate(date: uniqueDate, transactions: filteredTransactions.filter { $0.date?.isSameDayAs(uniqueDate) ?? false}))
                }
                currentTransactionsByDate = byDate.sorted {
                    $0.date > $1.date
                }
            }
        }
    }
    @Published var currentTransaction: Transaction? = nil
    @Published var filteredSelectedDate = Calendar.current.dateComponents([.month, .year], from: Date()) {
        didSet {
            filterTransactionList()
            isCurrentMonthSelected = filteredSelectedDate.month == currentDateComps.month && filteredSelectedDate.year == currentDateComps.year
        }
    }
    @Published var isCurrentMonthSelected: Bool = true
    
    private let currentDateComps: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
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
