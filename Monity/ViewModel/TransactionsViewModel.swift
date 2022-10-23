//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    static let shared = TransactionsViewModel()
    @Published var currentTransactionsByDate: [TransactionsByDate] = []
    @Published var transactions: [Transaction] = [] {
        didSet {
            filterTransactionList()
        }
    }
    @Published var filteredTransactions: [Transaction]? = nil {
        didSet {
            if let filteredTransactions {
                setOrUpdateTransactionsByDate(filteredTransactions)
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
            transaction.date?.isSameMonthAs(filteredSelectedDate.toDate) ?? false
        }
    }
    
    private func setTransactionsByDate(_ transactions: [Transaction]) {
        var byDate: [TransactionsByDate] = []
        let uniqueDates = Set(transactions.map { $0.date?.removeTimeStamp ?? Date() })
        for uniqueDate in uniqueDates {
            byDate.append(TransactionsByDate(date: uniqueDate, transactions: transactions.filter { $0.date?.isSameDayAs(uniqueDate) ?? false}))
        }
        currentTransactionsByDate = byDate.sorted {
            $0.date > $1.date
        }
    }
    
    private func updateTransactionsByDate(_ transactions: [Transaction]) {
        var byDate: [TransactionsByDate] = []
        let uniqueDates = Set(transactions.map { $0.date?.removeTimeStamp ?? Date() })
        for uniqueDate in uniqueDates {
            let newTransactions = transactions.filter { $0.date?.isSameDayAs(uniqueDate) ?? false }
            let existing = currentTransactionsByDate.first(where: { $0.date.isSameDayAs(uniqueDate)})
            if let existing {
                var newExisting = existing
                newExisting.setTransactions(newTransactions)
                byDate.append(newExisting)
            } else {
                byDate.append(TransactionsByDate(date: uniqueDate, transactions: newTransactions))
            }
        }
        currentTransactionsByDate = byDate.filter { !$0.transactions.isEmpty }.sorted {
            $0.date > $1.date
        }
    }
    
    private func setOrUpdateTransactionsByDate(_ transactions: [Transaction]) {
        if currentTransactionsByDate.isEmpty {
            setTransactionsByDate(transactions)
        } else {
            updateTransactionsByDate(transactions)
        }
    }
    
    // MARK: - Intents
    
    func deleteTransaction(_ transaction: Transaction) {
        TransactionStorage.shared.delete(transaction)
    }
}
