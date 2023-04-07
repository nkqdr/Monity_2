//
//  MonthExpenseCalculator.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import Foundation
import Combine

class MonthExpenseCalculator: ObservableObject, PieChartViewModel {
    static let current = MonthExpenseCalculator(date: Date())
    
    @Published var expenseDataPoints: [PieChartDataPoint] = []
    @Published var totalExpenses: Double = 0
    
    /// All recorded expenses in the current month
    private var expenses: [AbstractTransaction] = [] {
        didSet {
            expenseDataPoints = getPieChartDataPoints(for: expenses, with: .red)
            totalExpenses = expenseDataPoints.map { $0.value }.reduce(0, +)
        }
    }
    var transactionCancellable: AnyCancellable?
    
    init(date: Date) {
        let transactionPublisher = AbstractTransactionWrapper(date: date).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { items in
            self.expenses = items.filter({ $0.isExpense })
        }
    }
}
