//
//  MonthlyOverviewViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import Foundation
import Combine
import SwiftUI

class MonthlyOverviewViewModel: ObservableObject {
    @Published var spentThisMonth: Double = 0 {
        didSet {
            let currentDay: Int = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
            let spendingsPerDay: Double = spentThisMonth / Double(currentDay)
            let daysInMonth: Int = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 0
            predictedTotalSpendings = spendingsPerDay * Double(daysInMonth)
        }
    }
    @Published var remainingDays: Int = 0
    @Published var thisMonthTransactions: [Transaction] = [] {
        didSet {
            spentThisMonth = thisMonthTransactions.filter { $0.isExpense }.map { $0.amount }.reduce(0, +)
        }
    }
    @Published var transactions: [Transaction] = [] {
        didSet {
            thisMonthTransactions = transactions.filter { t in
                let comps = Calendar.current.dateComponents([.month, .year], from: t.date ?? Date())
                return comps.year == currentComps.year && comps.month == currentComps.month
            }
        }
    }
    @Published var predictedTotalSpendings: Double = 0
    
    private let currentComps: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
    private var startOfNextMonth: Date {
        let correctYear: Int = currentComps.month == 12 ? (currentComps.year ?? 0) + 1 : currentComps.year ?? 1
        let correctMonth: Int = currentComps.month == 12 ? 1 : (currentComps.month ?? 0) + 1
        return Calendar.current.date(from: DateComponents(year: correctYear, month: correctMonth, day: 1)) ?? Date()
    }
    private var transactionCancellable: AnyCancellable?
    
    // MARK: - TO BE REFINED
    
    @Published var sumInTimeframe: Double = 5226.71
    @Published var expenseSumInTimeframe: Double = 2521.10
    @Published var values: [Double] = [108.42, 95.12, 48.01]
    let colors: [Color] = [.green, .green.opacity(0.8), .green.opacity(0.6)]
    @Published var expenseValues: [Double] = [18.42, 85.12, 8.01, 50.1, 85.02, 142.01]
    let expenseColors: [Color] = [.red, .red.opacity(0.8), .red.opacity(0.6), .red.opacity(0.4), .red.opacity(0.2), .red.opacity(0.1)]
    var dataPoints: [PieChartDataPoint] {
        var dps: [PieChartDataPoint] = []
        for (index, color) in colors.enumerated() {
            dps.append(PieChartDataPoint(title: "Category \(index)", value: values[index], color: color))
        }
        return dps
    }
    var expenseDataPoints: [PieChartDataPoint] {
        var dps: [PieChartDataPoint] = []
        for (index, color) in expenseColors.enumerated() {
            dps.append(PieChartDataPoint(title: "Expense \(index)", value: expenseValues[index], color: color))
        }
        return dps
    }
    
    // MARK: - Constructor(s)
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
        remainingDays = (Calendar.current.dateComponents([.day], from: Date(), to: startOfNextMonth).day ?? 0) + 1
    }
}
