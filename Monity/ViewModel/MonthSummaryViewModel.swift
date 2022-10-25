//
//  MonthSummaryViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import Foundation
import Combine

class MonthSummaryViewModel: ObservableObject, PieChartViewModel {
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
    @Published var totalTransactionsAmount: Double = 0
    @Published var thisMonthTransactions: [Transaction] = [] {
        didSet {
            thisMonthExpenses = thisMonthTransactions.filter { $0.isExpense }
            thisMonthIncome = thisMonthTransactions.filter { !$0.isExpense }
            expenseDataPoints = getPieChartDataPoints(for: thisMonthExpenses, with: .red)
            incomeDataPoints = getPieChartDataPoints(for: thisMonthIncome, with: .green)
            totalTransactionsAmount = thisMonthTransactions.map { $0.amount }.reduce(0, +)
        }
    }
    @Published var thisMonthExpenses: [Transaction] = [] {
        didSet {
            spentThisMonth = thisMonthExpenses.map { $0.amount }.reduce(0, +)
        }
    }
    @Published var thisMonthIncome: [Transaction] = [] {
        didSet {
            earnedThisMonth = thisMonthIncome.map { $0.amount }.reduce(0, +)
        }
    }
    @Published var incomeDataPoints: [PieChartDataPoint] = []
    @Published var expenseDataPoints: [PieChartDataPoint] = []
    @Published var earnedThisMonth: Double = 0
    @Published var spentThisMonth: Double = 0
    
    private var transactionCancellable: AnyCancellable?
    private let transactionPublisher = TransactionStorage.shared.items.eraseToAnyPublisher()
    
    public init(monthDate: Date) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.thisMonthTransactions = transactions.filter { $0.date?.isSameMonthAs(monthDate) ?? false }
        }
    }
}
