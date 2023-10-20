//
//  AverageMonthlyChartViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import Foundation
import Combine
import Accelerate

class CategoryGrouper {
    struct YearMonth: Hashable {
        let year: Int
        let month: Int
    }
    
    static func group(data: [AbstractTransaction]) -> [ValueTimeDataPoint] {
        let groupedTransactions = Dictionary(grouping: data) { transaction in
            let components = Calendar.current.dateComponents([.year, .month], from: transaction.wrappedDate)
            return YearMonth(year: components.year!, month: components.month!)
        }

        let monthlySummaries: [(year: Int, month: Int, totalAmount: Double)] = groupedTransactions.map { key, transactions in
            let totalAmount = vDSP.sum(transactions.map { $0.amount })
            return (year: key.year, month: key.month, totalAmount: totalAmount)
        }.sorted { (lhs, rhs) -> Bool in
            if lhs.year != rhs.year {
                return lhs.year < rhs.year
            } else {
                return lhs.month < rhs.month
            }
        }
        return monthlySummaries.map {
            ValueTimeDataPoint(date: Calendar.current.date(from: DateComponents(year: $0.year, month: $0.month))!, value: $0.totalAmount)
        }
    }
}

class TransactionCategorySummaryViewModel: ObservableObject {
    @Published var fetchedTransactions: [AbstractTransaction] = [] {
        didSet {
            dataPoints = CategoryGrouper.group(data: fetchedTransactions);
        }
    }
    @Published var dataPoints: [ValueTimeDataPoint] = [] {
        didSet {
            let totalSum: Double = vDSP.sum(self.dataPoints.map { $0.value})
            let average: Double = vDSP.mean(self.dataPoints.map { $0.value})
            
            self.retroDP = CategoryRetroDataPoint(
                category: self.category,
                total: totalSum,
                average: average,
                numTransactions: self.fetchedTransactions.count
            )
            
            let lastYearDataPoints = self.dataPoints.filter { $0.date.isInLastYear}
            let lastYearTotalSum: Double = vDSP.sum(lastYearDataPoints.map { $0.value })
            let lastYearAverage: Double = vDSP.mean(lastYearDataPoints.map { $0.value})
            
            self.lastYearRetroDP = CategoryRetroDataPoint(
                category: self.category,
                total: lastYearTotalSum,
                average: lastYearAverage,
                numTransactions: self.fetchedTransactions.count
            )
        }
    }
    var retroDP: CategoryRetroDataPoint
    var lastYearRetroDP: CategoryRetroDataPoint
    var category: TransactionCategory
    var showExpenses: Bool
    
    private var transactionCancellable: AnyCancellable?
    private var transactionFetchController: TransactionFetchController
    private var abstractTransactionWrapper: AbstractTransactionWrapper
    
    init(category: TransactionCategory, showExpenses: Bool) {
        self.category = category
        self.showExpenses = showExpenses
        self.retroDP = CategoryRetroDataPoint(category: category, total: 0, average: 0, numTransactions: 0)
        self.lastYearRetroDP = CategoryRetroDataPoint(category: category, total: 0, average: 0, numTransactions: 0)
        self.transactionFetchController = TransactionFetchController(category: category, isExpense: showExpenses)
        self.abstractTransactionWrapper = AbstractTransactionWrapper(transactionController: self.transactionFetchController, recurringTransactionController: RecurringTransactionFetchController(category: category))
        let publisher = self.abstractTransactionWrapper.$wrappedTransactions.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { val in
            self.fetchedTransactions = val
        }
    }
}

class AverageMonthlyChartViewModel: ObservableObject {
    static let shared: AverageMonthlyChartViewModel = AverageMonthlyChartViewModel()
    @Published var showingExpenses: Bool = true
    @Published var expenseCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var incomeCategoryRetroDataPoints: [CategoryRetroDataPoint] = []
    @Published var allExpenseDataPoints: [ValueTimeDataPoint] = []
    @Published var allIncomeDataPoints: [ValueTimeDataPoint] = []

    var barChartDataPoints: [ValueTimeDataPoint] {
        showingExpenses ? allExpenseDataPoints : allIncomeDataPoints
    }
    
    var retroDataPoints: [CategoryRetroDataPoint] {
        showingExpenses ? expenseCategoryRetroDataPoints : incomeCategoryRetroDataPoints
    }
    
    private var transactions: [AbstractTransaction] = [] {
        didSet {
            allExpenseDataPoints = CategoryGrouper.group(data: transactions.filter { $0.isExpense })
            allIncomeDataPoints = CategoryGrouper.group(data: transactions.filter { !$0.isExpense })
            computeValues()
        }
    }
    
    private var transactionCategories: [TransactionCategory] = [] {
        didSet {
            computeValues()
        }
    }
    
    private var transactionCancellable: AnyCancellable?
    private var transactionCategoryCancellable: AnyCancellable?
    private let transactionWrapper: AbstractTransactionWrapper
    
    init() {
        self.transactionWrapper = AbstractTransactionWrapper()
        let transactionPublisher = self.transactionWrapper.$wrappedTransactions.eraseToAnyPublisher()
        let categoryPublisher = TransactionCategoryFetchController.all.items.eraseToAnyPublisher()
        transactionCategoryCancellable = categoryPublisher.sink { categories in
            self.transactionCategories = categories
        }
        transactionCancellable = transactionPublisher.sink { transactions in
            self.transactions = transactions
        }
    }
    
    // MARK: - Helper functions
    
    private func updateFilteredRetroDataPoints(isExpense: Bool) -> [CategoryRetroDataPoint] {
        var dataPoints: [CategoryRetroDataPoint] = []
        for category in transactionCategories {
            let usedTransactions: [AbstractTransaction] = transactions.filter { $0.category == category && $0.isExpense == isExpense && $0.date?.isInLastYear ?? false }
            let groupedDataPoints = CategoryGrouper.group(data: usedTransactions)
            let totalSum: Double = vDSP.sum(groupedDataPoints.map { $0.value})
            let average: Double = vDSP.mean(groupedDataPoints.map { $0.value})
            
            if totalSum > 0 {
                dataPoints.append(CategoryRetroDataPoint(category: category, total: totalSum, average: average, numTransactions: usedTransactions.count))
            }
        }
        return dataPoints.sorted {
            $0.total > $1.total
        }
    }
    
    private func computeValues() {
        expenseCategoryRetroDataPoints = updateFilteredRetroDataPoints(isExpense: true)
        incomeCategoryRetroDataPoints = updateFilteredRetroDataPoints(isExpense: false)
    }
}
