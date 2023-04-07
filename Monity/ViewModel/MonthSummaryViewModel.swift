//
//  MonthSummaryViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import Foundation
import Combine

class MonthSummaryViewModel: ObservableObject {
    struct IncomeExpenseRelationDataPoint: Identifiable {
        var id = UUID()
        var amount: Double
        var type: String
    }
    
    var incomeExpenseRelationData: [IncomeExpenseRelationDataPoint] {
        [
            IncomeExpenseRelationDataPoint(amount: spentThisMonth / (totalTransactionsAmount), type: "Expenses"),
            IncomeExpenseRelationDataPoint(amount: earnedThisMonth / (totalTransactionsAmount), type: "Income")
        ]
    }
    private var totalTransactionsAmount: Double = 0
    private var earnedThisMonth: Double = 0
    private var spentThisMonth: Double = 0
    private var thisMonthTransactions: [AbstractTransaction] = [] {
        didSet {
            totalTransactionsAmount = thisMonthTransactions.map { $0.amount }.reduce(0, +)
            spentThisMonth = thisMonthTransactions.filter { $0.isExpense }.map { $0.amount }.reduce(0, +)
            earnedThisMonth = thisMonthTransactions.filter { !$0.isExpense }.map { $0.amount }.reduce(0, +)
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    
    public init(monthDate: Date) {
        let transactionPublisher = AbstractTransactionWrapper(date: monthDate).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { transactions in
            self.thisMonthTransactions = transactions.filter { $0.date?.isSameMonthAs(monthDate) ?? false }
        }
    }
}
