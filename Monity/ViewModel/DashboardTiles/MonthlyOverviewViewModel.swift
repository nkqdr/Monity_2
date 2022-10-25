//
//  MonthlyOverviewViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import Foundation
import Combine
import SwiftUI

class MonthlyOverviewViewModel: ObservableObject, PieChartViewModel, CashflowViewModel {
    @Published var incomeDataPoints: [PieChartDataPoint] = []
    @Published var expenseDataPoints: [PieChartDataPoint] = []
    @Published var cashFlowData: [ValueTimeDataPoint] = []
    
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
            cashFlowData = getCashFlowDataPoints(for: thisMonthTransactions)
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
    
    private let currentComps: DateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    private var startOfNextMonth: Date {
        let correctYear: Int = currentComps.month == 12 ? (currentComps.year ?? 0) + 1 : currentComps.year ?? 1
        let correctMonth: Int = currentComps.month == 12 ? 1 : (currentComps.month ?? 0) + 1
        return Calendar.current.date(from: DateComponents(year: correctYear, month: correctMonth, day: 1)) ?? Date()
    }
    private var transactionCancellable: AnyCancellable?
    
    // MARK: - Constructor(s)
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.items.eraseToAnyPublisher()) {
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
        remainingDays = (Calendar.current.dateComponents([.day], from: Date(), to: startOfNextMonth).day ?? 0) + 1
    }
}
