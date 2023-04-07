//
//  MonthIncomeCalculator.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import Foundation
import Combine

class MonthIncomeCalculator: ObservableObject, PieChartViewModel {
    static let current = MonthIncomeCalculator(date: Date())
    
    @Published var incomeDataPoints: [PieChartDataPoint] = []
    @Published var totalIncome: Double = 0
    
    /// All recorded income entries in the current month
    private var income: [AbstractTransaction] = [] {
        didSet {
            incomeDataPoints = getPieChartDataPoints(for: income, with: .green)
            totalIncome = incomeDataPoints.map { $0.value }.reduce(0, +)
        }
    }
    var transactionCancellable: AnyCancellable?
    
    init(date: Date) {
        let transactionPublisher = AbstractTransactionWrapper(date: date).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { items in
            self.income = items.filter({ !$0.isExpense })
        }
    }
    
}
