//
//  EOYViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.23.
//

import Foundation
import Accelerate
import Combine

class YearlyCashflowViewModel: ObservableObject {
    @Published var data: [ValueTimeDataPoint] = []
    private var allTransactions: [AbstractTransaction] = []
    
    private var transactionCancellable: AnyCancellable?
    private var transactionWrapper: AbstractTransactionWrapper
    
    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startOfYear: Date = Calendar.current.date(from: DateComponents(
            year: currentYear,
            month: 1,
            day: 1)
        )!
        self.transactionWrapper = AbstractTransactionWrapper(startDate: startOfYear, endDate: Date())
        self.transactionCancellable = self.transactionWrapper.$wrappedTransactions.sink { newVal in
            self.allTransactions = newVal
            self.data = self.computeCashFlowDataPoints()
        }
    }
    
    private func computeCashFlowDataPoints() -> [ValueTimeDataPoint] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startOfYearDate = Calendar.current.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        return LineChartDataBuilder.generateCashflowData(for: self.allTransactions, initialDate: startOfYearDate)
    }
}

class EOYViewModel: ObservableObject {
    typealias CategoryWithAmount = (category: TransactionCategory, totalAmount: Double)
    struct CashflowTimeData: Hashable {
        var month: Int
        var day: Int
    }
    @Published var currentlyDisplayedTabIndex: Int = 0
    @Published var totalAmountOfTransactions: Int = 0
    @Published var totalAmountOfIncomeTransactions: Int = 0
    @Published var totalAmountOfExpenseTransactions: Int = 0
    @Published var totalExpenses: Double = 0
    @Published var totalIncome: Double = 0
    @Published var mostExpensiveCategories: [CategoryWithAmount] = []
    @Published var mostIncomeCategories: [CategoryWithAmount] = []
    @Published var savingsDataPoints: [ValueTimeDataPoint] = []
    
    private var allTransactions: [AbstractTransaction] = []
    
    private var transactionCancellable: AnyCancellable?
    private var savingsCancellable: AnyCancellable?
    private var transactionWrapper: AbstractTransactionWrapper
    private var savingsFetchController: SavingsFetchController
    
    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startOfYear: Date = Calendar.current.date(from: DateComponents(
            year: currentYear,
            month: 1,
            day: 1)
        )!
        self.savingsFetchController = SavingsFetchController.all
        let savingsPublisher = self.savingsFetchController.items.eraseToAnyPublisher()
        self.transactionWrapper = AbstractTransactionWrapper(startDate: startOfYear, endDate: Date())
        self.transactionCancellable = self.transactionWrapper.$wrappedTransactions.sink { newVal in
            self.allTransactions = newVal
            self.totalAmountOfTransactions = newVal.count
            self.totalAmountOfIncomeTransactions = newVal.filter { !$0.isExpense }.count
            self.totalAmountOfExpenseTransactions = self.totalAmountOfTransactions - self.totalAmountOfIncomeTransactions
            self.totalIncome = vDSP.sum(newVal.filter { !$0.isExpense }.map { $0.amount })
            self.totalExpenses = vDSP.sum(newVal.filter { $0.isExpense }.map { $0.amount })
            self.mostExpensiveCategories = self.computeMostExpensiveCategories(isExpense: true)
            self.mostIncomeCategories = self.computeMostExpensiveCategories(isExpense: false)
        }
        self.savingsCancellable = savingsPublisher.sink { entries in
            self.savingsDataPoints = LineChartDataBuilder.generateSavingsLineChartData(for: entries, lowerBound: startOfYear, allowAnimation: false)
        }
    }
    
    private func computeMostExpensiveCategories(isExpense: Bool) -> [CategoryWithAmount] {
        let groupedTransactions = Dictionary(grouping: self.allTransactions.filter { $0.category != nil && $0.isExpense == isExpense }) { transaction in
            return transaction.category!
        }

        return groupedTransactions.map { key, transactions in
            let totalAmount = vDSP.sum(transactions.map { $0.amount })
            return (key, totalAmount: totalAmount)
        }.sorted { (lhs, rhs) -> Bool in
            return lhs.totalAmount > rhs.totalAmount
        }
    }
}
