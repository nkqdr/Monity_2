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
            createTransactionByCategoryDict()
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
    
    let incomePieChartColors: [Color] = [.green, .green.opacity(0.8), .green.opacity(0.6), .green.opacity(0.4), .green.opacity(0.2), .green.opacity(0.1)]
    let expensePieChartColors: [Color] = [.red, .red.opacity(0.8), .red.opacity(0.6), .red.opacity(0.4), .red.opacity(0.2), .red.opacity(0.1)]
    
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
    private func createTransactionByCategoryDict() {
        var expenseByCategory: [String?:Double] = [:]
        var incomeByCategory: [String?:Double] = [:]
        let usedExpenseCategoryNames: Set<String?> = Set(thisMonthExpenses.map { $0.category?.name })
        let usedIncomeCategoryNames: Set<String?> = Set(thisMonthIncome.map { $0.category?.name })
        for usedExpenseCategoryName in usedExpenseCategoryNames {
            expenseByCategory[usedExpenseCategoryName] = thisMonthExpenses.filter { $0.category?.name == usedExpenseCategoryName }.map { $0.amount }.reduce(0, +)
        }
        for usedIncomeCategoryName in usedIncomeCategoryNames {
            incomeByCategory[usedIncomeCategoryName] = thisMonthIncome.filter { $0.category?.name == usedIncomeCategoryName }.map { $0.amount }.reduce(0, +)
        }
        var expense_dps: [PieChartDataPoint] = []
        var income_dps: [PieChartDataPoint] = []
        for (index, (categoryName, sum)) in expenseByCategory.enumerated() {
            expense_dps.append(PieChartDataPoint(title: categoryName ?? "No category", value: sum, color: expensePieChartColors[index]))
        }
        expense_dps.sort(by: {one, two in one.value > two.value})
        for (index, (categoryName, sum)) in incomeByCategory.enumerated() {
            income_dps.append(PieChartDataPoint(title: categoryName ?? "No category", value: sum, color: incomePieChartColors[index]))
        }
        income_dps.sort(by: {one, two in one.value > two.value})
        expenseDataPoints = expense_dps
        incomeDataPoints = income_dps
    }
}
