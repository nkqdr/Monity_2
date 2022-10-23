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
    @Published var expenseCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var incomeCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var totalExpensesThisYear: Double = 0
    @Published var totalIncomeThisYear: Double = 0
    
    private var transactions: [Transaction] = [] {
        didSet {
            monthlyExpenseDataPoints = getPastYearExpenseDataPoints()
            monthlyIncomeDataPoints = getPastYearIncomeDataPoints()
            expenseCategoryRetroDataPoints = getExpenseRetroDataPoints()
            incomeCategoryRetroDataPoints = getIncomeRetroDataPoints()
            totalExpensesThisYear = monthlyExpenseDataPoints.map { $0.value }.reduce(0, +)
            totalIncomeThisYear = monthlyIncomeDataPoints.map { $0.value }.reduce(0, +)
            averageExpenses = totalExpensesThisYear / Double(monthlyExpenseDataPoints.count)
            averageIncome = totalIncomeThisYear / Double(monthlyIncomeDataPoints.count)
        }
    }
    
    private var transactionCategories: [TransactionCategory] = []
    
    private var transactionCancellable: AnyCancellable?
    private var transactionCategoryCancellable: AnyCancellable?
    
    init(transactionPublisher: AnyPublisher<[Transaction], Never> = TransactionStorage.shared.transactions.eraseToAnyPublisher()) {
        let categoryPublisher = TransactionCategoryStorage.shared.categories.eraseToAnyPublisher()
        transactionCategoryCancellable = categoryPublisher.sink { categories in
            self.transactionCategories = categories
        }
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
    
    private func generateFilteredRetroDataPoints(isExpense: Bool) -> [CategoryRetroDataPoint] {
        var dataPoints: [CategoryRetroDataPoint] = []
        for category in transactionCategories {
            let usedTransactions: [Transaction] = transactions.filter { $0.category == category && $0.isExpense == isExpense }
            let totalSum: Double = usedTransactions.map { $0.amount}.reduce(0, +)
            let average: Double = totalSum / Double(monthlyExpenseDataPoints.count)
            if totalSum > 0 {
                dataPoints.append(CategoryRetroDataPoint(category: category, total: totalSum, average: average, numTransactions: usedTransactions.count))
            }
        }
        return dataPoints.sorted {
            $0.total > $1.total
        }
    }
    
    private func getIncomeRetroDataPoints() -> [CategoryRetroDataPoint] {
        return generateFilteredRetroDataPoints(isExpense: false)
    }
    
    private func getExpenseRetroDataPoints() -> [CategoryRetroDataPoint] {
        return generateFilteredRetroDataPoints(isExpense: true)
    }
}
