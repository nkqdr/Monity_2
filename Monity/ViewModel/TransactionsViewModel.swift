//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine

class MonthlyTransactionsViewModel: ItemListViewModel<Transaction> {
    @Published var currentTransactionsByDate: [TransactionsByDate] = []
    @Published var isCurrentMonthSelected: Bool = true
    @Published var filteredSelectedDate: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date()) {
        didSet {
            // Update the FetchController
            self.itemCancellable?.cancel()
            self.fetchController = TransactionFetchController(month: filteredSelectedDate.month, year: filteredSelectedDate.year)
            let publisher = self.fetchController.items.eraseToAnyPublisher()
            self.itemCancellable = publisher.sink { items in
                self.items = items
            }
            
            // Correctly set currentMonthSelected
            self.isCurrentMonthSelected = filteredSelectedDate.month == currentDateComps.month && filteredSelectedDate.year == currentDateComps.year
        }
    }
    @Published var filteredTransactions: [Transaction]? = nil {
        didSet {
            if let filteredTransactions {
                updateTransactionsByDate(filteredTransactions)
            } else {
                updateTransactionsByDate()
            }
        }
    }
    
    private var fetchController: TransactionFetchController
    private let currentDateComps: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
    
    init() {
        self.fetchController = TransactionFetchController.currentMonth
        let publisher = fetchController.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    override func onItemsSet() {
        updateTransactionsByDate()
    }
    
    private func updateTransactionsByDate(_ transactionList: [Transaction]? = nil) {
        let transactions = transactionList ?? self.items
        let uniqueDates = Set(transactions.map { $0.date?.removeTimeStamp ?? Date() })
        
        var byDate: [TransactionsByDate] = []
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
    
    // MARK: - Intents
    
    public func filterTransactionsByValue(_ value: String) {
        if value.isEmpty {
            filteredTransactions = nil
            return
        }
        filteredTransactions = self.items.filter {
            $0.category?.wrappedName.lowercased().contains(value.lowercased()) ?? false
            || $0.wrappedText.lowercased().contains(value.lowercased())
        }
    }
    
    override func deleteItem(_ item: Transaction) {
        TransactionStorage.main.delete(item)
    }
    
}

class TransactionsViewModel: ItemListViewModel<Transaction> {
    static let shared = TransactionsViewModel()
    
    private let fetchController = TransactionFetchController.all
    
    init() {
        let publisher = fetchController.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
}
