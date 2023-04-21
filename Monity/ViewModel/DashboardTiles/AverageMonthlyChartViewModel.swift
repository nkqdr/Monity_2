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
    @Published var showingExpenses: Bool = true
    @Published var averageExpenses: Double = 0
    @Published var averageIncome: Double = 0
    @Published var monthlyExpenseDataPoints: [ValueTimeDataPoint] = []
    @Published var monthlyIncomeDataPoints: [ValueTimeDataPoint] = []
    @Published var expenseCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var incomeCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var totalExpensesThisYear: Double = 0
    @Published var totalIncomeThisYear: Double = 0
    @Published var selectedUpperBoundDate: Date = Date() {
        didSet {
            updateChartDataPoints()
        }
    }
    var barChartDataPoints: [ValueTimeDataPoint] {
        showingExpenses ? monthlyExpenseDataPoints : monthlyIncomeDataPoints
    }
    var averageValue: Double {
        showingExpenses ? averageExpenses : averageIncome
    }
    var retroDataPoints: [CategoryRetroDataPoint] {
        showingExpenses ? expenseCategoryRetroDataPoints : incomeCategoryRetroDataPoints
    }
    var totalValue: Double {
        showingExpenses ? totalExpensesThisYear : totalIncomeThisYear
    }
    private var allExpenseDataPoints: [ValueTimeDataPoint] = []
    private var allIncomeDataPoints: [ValueTimeDataPoint] = []
    private var allExpenseRetroDataPoints: [CategoryRetroDataPoint] = []
    private var allIncomeRetroDataPoints: [CategoryRetroDataPoint] = []
    
    var selectedLowerBoundDate: Date {
        Calendar.current.date(byAdding: DateComponents(year: -1), to: selectedUpperBoundDate) ?? Date()
    }
    
    private var transactions: [AbstractTransaction] = [] {
        didSet {
            allExpenseDataPoints = createValueTimeDataPoints(isExpense: true)
            allIncomeDataPoints = createValueTimeDataPoints(isExpense: false)
            updateChartDataPoints()
            computeValues()
        }
    }
    
    private var transactionCategories: [TransactionCategory] = [] {
        didSet {
            expenseCategoryRetroDataPoints = getExpenseRetroDataPoints()
            incomeCategoryRetroDataPoints = getIncomeRetroDataPoints()
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    private var transactionCategoryCancellable: AnyCancellable?
    
    init() {
        let transactionPublisher = AbstractTransactionWrapper().$wrappedTransactions.eraseToAnyPublisher()
        let categoryPublisher = TransactionCategoryStorage.shared.items.eraseToAnyPublisher()
        transactionCategoryCancellable = categoryPublisher.sink { categories in
            self.transactionCategories = categories
        }
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    // MARK: - Helper functions
    
    private func createValueTimeDataPoints(isExpense: Bool) -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        let relevantTransactions = transactions.filter { $0.isExpense == isExpense }
        let uniqueMonths: Set<Date> = Set(relevantTransactions.map { $0.date?.removeTimeStampAndDay ?? Date() }.sorted())
        for date in uniqueMonths {
            dataPoints.append(
                ValueTimeDataPoint(date: date, value: relevantTransactions.filter {
                    $0.date?.isSameMonthAs(date) ?? false
                }.map { $0.amount }.reduce(0, +))
            )
        }
        return dataPoints.sorted { v1, v2 in
            return v1.date < v2.date
        }
    }
    
    private func updateFilteredRetroDataPoints(isExpense: Bool) -> [CategoryRetroDataPoint] {
        var dataPoints: [CategoryRetroDataPoint] = []
        for category in transactionCategories {
            let usedTransactions: [AbstractTransaction] = transactions.filter { $0.category == category && $0.isExpense == isExpense && $0.date?.isInLastYear ?? false }
            let totalSum: Double = usedTransactions.map { $0.amount}.reduce(0, +)
            let average: Double = totalSum / Double(isExpense ? monthlyExpenseDataPoints.count : monthlyIncomeDataPoints.count)
            var existing: CategoryRetroDataPoint?
            if isExpense {
                existing = expenseCategoryRetroDataPoints.first(where: { $0.category == category })
            } else {
                existing = incomeCategoryRetroDataPoints.first(where: { $0.category == category })
            }
            if let existing, totalSum > 0 {
                var newExisting = existing
                newExisting.setTotal(totalSum)
                newExisting.setAverage(average)
                newExisting.setNumTransactinos(usedTransactions.count)
                dataPoints.append(newExisting)
            } else if totalSum > 0 {
                dataPoints.append(CategoryRetroDataPoint(category: category, total: totalSum, average: average, numTransactions: usedTransactions.count))
            }
        }
        return dataPoints.sorted {
            $0.total > $1.total
        }
    }
    
    private func computeValues() {
        expenseCategoryRetroDataPoints = getExpenseRetroDataPoints()
        incomeCategoryRetroDataPoints = getIncomeRetroDataPoints()
        
    }
    
    private func updateChartDataPoints() {
        monthlyExpenseDataPoints = allExpenseDataPoints.filter {
            selectedLowerBoundDate.removeTimeStampAndDay! < $0.date.removeTimeStampAndDay!
            && $0.date.removeTimeStampAndDay! <= selectedUpperBoundDate.removeTimeStampAndDay!
        }
        monthlyIncomeDataPoints = allIncomeDataPoints.filter {
            selectedLowerBoundDate.removeTimeStampAndDay! < $0.date.removeTimeStampAndDay!
            && $0.date.removeTimeStampAndDay! <= selectedUpperBoundDate.removeTimeStampAndDay!
        }
        totalExpensesThisYear = monthlyExpenseDataPoints.map { $0.value }.reduce(0, +)
        totalIncomeThisYear = monthlyIncomeDataPoints.map { $0.value }.reduce(0, +)
        averageExpenses = totalExpensesThisYear / Double(monthlyExpenseDataPoints.count)
        averageIncome = totalIncomeThisYear / Double(monthlyIncomeDataPoints.count)
    }

    private func getIncomeRetroDataPoints() -> [CategoryRetroDataPoint] {
        return updateFilteredRetroDataPoints(isExpense: false)
    }

    private func getExpenseRetroDataPoints() -> [CategoryRetroDataPoint] {
        return updateFilteredRetroDataPoints(isExpense: true)
    }
    
    // MARK: - Intents
    
    private func dragChartRight() -> Bool {
        let newVal = Calendar.current.date(byAdding: DateComponents(month: -1), to: selectedUpperBoundDate) ?? Date()
        if (showingExpenses && allExpenseDataPoints.first?.date.isSameMonthAs(Calendar.current.date(byAdding: DateComponents(year: -1, month: 2), to: newVal) ?? Date()) ?? true ) {
            return false
        }
        if (!showingExpenses && allIncomeDataPoints.first?.date.isSameMonthAs(Calendar.current.date(byAdding: DateComponents(year: -1, month: 2), to: newVal) ?? Date()) ?? true ) {
            return false
        }
        selectedUpperBoundDate = newVal
        return true
    }
    
    private func dragChartLeft() -> Bool {
        if (selectedUpperBoundDate.isSameMonthAs(Date())) {
            return false
        }
        selectedUpperBoundDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: selectedUpperBoundDate) ?? Date()
        return true
    }
    
    public func drag(direction: Double) -> Bool {
        if (direction > 0) {
            return dragChartRight()
        } else {
            return dragChartLeft()
        }
    }
    
    public func handleDragEnd() {
        computeValues()
    }
}
