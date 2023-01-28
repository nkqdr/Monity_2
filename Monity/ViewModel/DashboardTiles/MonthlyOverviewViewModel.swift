//
//  MonthlyOverviewViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import Foundation
import Combine
import SwiftUI

class MonthlyOverviewViewModel: ItemListViewModel<Transaction>, PieChartViewModel, CashflowViewModel {
    @Published var incomeDataPoints: [PieChartDataPoint] = []
    @Published var expenseDataPoints: [PieChartDataPoint] = []
    @Published var cashFlowData: [ValueTimeDataPoint] = []
    @Published var spendingsPerDay: Double = 0 {
        didSet {
            let daysInMonth: Int = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 0
            predictedTotalSpendings = spendingsPerDay * Double(daysInMonth)
        }
    }
    @Published var spentThisMonth: Double = 0 {
        didSet {
            let currentDay: Int = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
            spendingsPerDay = spentThisMonth / Double(currentDay)
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
    
    // MARK: - Constructor(s)
    
    init() {
        let publisher = TransactionStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
        remainingDays = (Calendar.current.dateComponents([.day], from: Date(), to: startOfNextMonth).day ?? 0) + 1
    }
    
    override func onItemsSet() {
        thisMonthTransactions = items.filter { t in
            let comps = Calendar.current.dateComponents([.month, .year], from: t.date ?? Date())
            return comps.year == currentComps.year && comps.month == currentComps.month
        }
    }
}
