//
//  TransactionsCategorySummaryViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import Foundation
import Combine

class TransactionsCategorySummaryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = [] {
        didSet {
            let relevantTransactions = transactions.filter { $0.category == selectedCategory }
            updateTransactionsByDate(relevantTransactions)
        }
    }
    @Published var transactionsByDate: [TransactionsByDate] = []
    
    private var transactionCancellable: AnyCancellable?
    private var selectedCategory: TransactionCategory
    
    init(category: TransactionCategory) {
        self.selectedCategory = category
        let transactionPublisher = TransactionStorage.shared.transactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    private func updateTransactionsByDate(_ transactions: [Transaction]) {
        var byDate: [TransactionsByDate] = []
        let uniqueDates = Set(transactions.map { $0.date?.removeTimeStampAndDay ?? Date() })
        for uniqueDate in uniqueDates {
            let newTransactions = transactions.filter { $0.date?.isSameMonthAs(uniqueDate) ?? false }
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
