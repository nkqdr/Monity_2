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
    @Published var incomeDataPoints: [PieChartDataPoint] = []
    @Published var expenseDataPoints: [PieChartDataPoint] = []
    
    @Published var spentThisMonth: Double = 0 {
        didSet {
            let currentDay: Int = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
            let spendingsPerDay: Double = spentThisMonth / Double(currentDay)
            let daysInMonth: Int = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 0
            predictedTotalSpendings = spendingsPerDay * Double(daysInMonth)
        }
    }
    @Published var earnedThisMonth: Double = 0
    @Published var remainingDays: Int = 0
    @Published var thisMonthTransactions: [Transaction] = [] {
        didSet {
            thisMonthExpenses = thisMonthTransactions.filter { $0.isExpense }
            thisMonthIncome = thisMonthTransactions.filter { !$0.isExpense }
            expenseDataPoints = getPieChartDataPoints(for: thisMonthExpenses, with: .red)
            incomeDataPoints = getPieChartDataPoints(for: thisMonthIncome, with: .green)
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
    
    private let currentComps: DateComponents = Calendar.current.dateComponents([.month, .year], from: Date())
    private var startOfNextMonth: Date {
        let correctYear: Int = currentComps.month == 12 ? (currentComps.year ?? 0) + 1 : currentComps.year ?? 1
        let correctMonth: Int = currentComps.month == 12 ? 1 : (currentComps.month ?? 0) + 1
        return Calendar.current.date(from: DateComponents(year: correctYear, month: correctMonth, day: 1)) ?? Date()
    }
    private var transactionCancellable: AnyCancellable?
    
    // MARK: - Constructor(s)
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
        remainingDays = (Calendar.current.dateComponents([.day], from: Date(), to: startOfNextMonth).day ?? 0) + 1
    }
    
    // MARK: - Helper functions
    
    private func getPieChartDataPoints(for transactions: [Transaction], with color: Color) -> [PieChartDataPoint] {
        var byCategory: [String?:Double] = [:]
        let usedCategoryNames: Set<String?> = Set(transactions.map { $0.category?.name })
        for usedCategoryName in usedCategoryNames {
            byCategory[usedCategoryName] = transactions.filter { $0.category?.name == usedCategoryName }.map { $0.amount }.reduce(0, +)
        }
        var dps: [PieChartDataPoint] = []
        let sorted = byCategory.keys.sorted(by: {(first, second) in
            return byCategory[first]! > byCategory[second]!
        })
        let totalDataPoints: Double = Double(sorted.count)
        for (index, categoryName) in sorted.enumerated() {
            let opacity: Double = 1.0 - (Double(index) / totalDataPoints)
            dps.append(PieChartDataPoint(title: categoryName ?? "No category", value: byCategory[categoryName] ?? 0, color: color.opacity(opacity)))
        }
        return dps
    }
}
