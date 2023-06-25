//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class TransactionsViewModel: ItemListViewModel<Transaction> {
    static let shared = TransactionsViewModel()
    @Published var currentTransactionsByDate: [TransactionsByDate] = []
    @Published var filteredTransactions: [Transaction]? = nil {
        didSet {
            if let filteredTransactions {
                setOrUpdateTransactionsByDate(filteredTransactions)
            }
        }
    }
    @Published var filteredSelectedDate = Calendar.current.dateComponents([.month, .year], from: Date()) {
        didSet {
            filterTransactionList()
            isCurrentMonthSelected = filteredSelectedDate.month == currentDateComps.month && filteredSelectedDate.year == currentDateComps.year
        }
    }
    @Published var isCurrentMonthSelected: Bool = true
    
    private let currentDateComps: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
    
    init() {
        let publisher = TransactionFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    override func onItemsSet() {
        print("Updating items...")
        filterTransactionList()
    }
    
    // MARK: - Helper functions
    private func filterTransactionList() {
        filteredTransactions = items.filter { transaction in
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
    
    public func resetTransactionsSearch() {
        filterTransactionList()
    }
    
    public func filterTransactionsByValue(_ value: String) {
        filteredTransactions = filteredTransactions?.filter {
            $0.category?.wrappedName.contains(value) ?? false
            || $0.wrappedText.contains(value)
        }
    }
    
    override func deleteItem(_ item: Transaction) {
        TransactionStorage.delete(item)
    }
}
