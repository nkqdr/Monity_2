//
//  TransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import Foundation
import Combine
import Algorithms

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
        let chunkedTransactions = transactions.chunked(by: {
            Calendar.current.isDate($0.wrappedDate, inSameDayAs: $1.wrappedDate)
        })
        var byDate: [TransactionsByDate] = []
        for chunk in chunkedTransactions {
            let day = chunk.first?.wrappedDate ?? Date()
            let transactionBlock = currentTransactionsByDate.first(where: { Calendar.current.isDate(day, inSameDayAs: $0.date)})
            guard let transactionBlock else {
                byDate.append(TransactionsByDate(date: day, transactions: Array(chunk)))
                continue
            }
            var newBlock = transactionBlock
            newBlock.setTransactions(Array(chunk))
            byDate.append(newBlock)
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
