//
//  TransactionListPerCategoryViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import Foundation
import Combine

class TransactionListPerCategoryViewModel: ObservableObject {
    private var transactions: [Transaction] = [] {
        didSet {
            relevantTransactions = transactions.filter { $0.category == selectedCategory }
        }
    }
    @Published var relevantTransactions: [Transaction] = [] {
        didSet {
            updateTransactionsByDate(relevantTransactions)
        }
    }
    @Published var transactionsByDate: [TransactionsByDate] = []
    
    private var transactionCancellable: AnyCancellable?
    private var selectedCategory: TransactionCategory
    private var showExpenses: Bool
    private let fetchController = TransactionFetchController.all
    
    init(category: TransactionCategory, showExpenses: Bool) {
        self.selectedCategory = category
        self.showExpenses = showExpenses
        let transactionPublisher = fetchController.items.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    private func updateTransactionsByDate(_ transactions: [Transaction]) {
        var byDate: [TransactionsByDate] = []
        let uniqueDates = Set(relevantTransactions.map { $0.date?.removeTimeStampAndDay ?? Date() })
        for uniqueDate in uniqueDates {
            let newTransactions = relevantTransactions.filter { $0.date?.isSameMonthAs(uniqueDate) ?? false && $0.isExpense == showExpenses }
            let existing = transactionsByDate.first(where: { $0.date.isSameMonthAs(uniqueDate)})
            if let existing {
                var newExisting = existing
                newExisting.setTransactions(newTransactions)
                byDate.append(newExisting)
            } else {
                byDate.append(TransactionsByDate(date: uniqueDate, transactions: newTransactions))
            }
        }
        transactionsByDate = byDate.filter { !$0.transactions.isEmpty }.sorted {
            $0.date > $1.date
        }
    }
}
