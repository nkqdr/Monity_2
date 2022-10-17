//
//  AverageMonthlyChartViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import Foundation
import Combine

class AverageMonthlyChartViewModel: ObservableObject {
    static let shared: AverageMonthlyChartViewModel = .init()
    @Published var averageExpenses: Double = 0
    @Published var averageIncome: Double = 0
    @Published var monthlyExpenseDataPoints: [ValueTimeDataPoint] = []
    @Published var monthlyIncomeDataPoints: [ValueTimeDataPoint] = []
    
    private var transactions: [Transaction] = [] {
        didSet {
            monthlyExpenseDataPoints = getPastYearExpenseDataPoints()
            monthlyIncomeDataPoints = getPastYearIncomeDataPoints()
            averageExpenses = monthlyExpenseDataPoints.map { $0.value }.reduce(0, +) / Double(monthlyExpenseDataPoints.count)
            averageIncome = monthlyIncomeDataPoints.map { $0.value }.reduce(0, +) / Double(monthlyIncomeDataPoints.count)
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    // MARK: - Helper functions
    
    private func filterPastYearDataPointsBy(isExpense: Bool) -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        let uniqueMonths: Set<Date> = Set(transactions.filter { $0.date?.isInLastYear ?? false }.map { $0.date?.removeTimeStampAndDay ?? Date() }.sorted())
        for date in uniqueMonths {
            dataPoints.append(
                ValueTimeDataPoint(date: date, value: transactions.filter {
                    (isExpense == $0.isExpense) && $0.date?.isSameMonthAs(date) ?? false
                }.map { $0.amount }.reduce(0, +))
            )
        }
        return dataPoints
    }
    
    private func getPastYearExpenseDataPoints() -> [ValueTimeDataPoint] {
        return filterPastYearDataPointsBy(isExpense: true)
    }
    
    private func getPastYearIncomeDataPoints() -> [ValueTimeDataPoint] {
        return filterPastYearDataPointsBy(isExpense: false)
    }
}
