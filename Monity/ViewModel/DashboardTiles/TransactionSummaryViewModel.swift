//
//  TransactionSummaryViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 08.07.23.
//

import Foundation
import Combine
import Accelerate
import Algorithms

class TransactionSummaryViewModel: ObservableObject {
    @Published var transactions: [AbstractTransaction] = [] {
        didSet {
            self.expenseBarChartData = createData(isExpense: true)
            self.incomeBarChartData = createData(isExpense: false)
            self.averageIncome = vDSP.mean(self.incomeBarChartData.map { $0.value })
            self.averageExpenses = vDSP.mean(self.expenseBarChartData.map { $0.value })
            self.percentageOfIncomeSpent = calculatePercentageSpent()
        }
    }
    @Published var expenseBarChartData: [ValueTimeDataPoint] = []
    @Published var incomeBarChartData: [ValueTimeDataPoint] = []
    @Published var averageExpenses: Double = 0
    @Published var averageIncome: Double = 0
    var percentageOfIncomeSpent: Double? = 0
    
    
    private var transactionCancellable: AnyCancellable?
    
    public init() {
        let today = Date().endOfThisMonth
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1, day: 1), to: today)?.startOfThisMonth ?? today
        
        let publisher = AbstractTransactionWrapper(startDate: oneYearAgo, endDate: today).$wrappedTransactions.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { value in
            self.transactions = value.sorted(by: {
                $0.wrappedDate <= $1.wrappedDate
            })
        }
    }
    
    private func calculatePercentageSpent() -> Double? {
        let expenses = vDSP.sum(self.expenseBarChartData.map { $0.value })
        let income = vDSP.sum(self.incomeBarChartData.map { $0.value })
        guard income > 0 else { return nil }
        return expenses / income
    }
    
    private func createData(isExpense: Bool) -> [ValueTimeDataPoint] {
        let transactionsToUse = self.transactions.filter { $0.isExpense == isExpense }
        let chunkedTransactions = transactionsToUse.chunked(by: {
            $0.wrappedDate.isSameMonthAs($1.wrappedDate)
        })
        return chunkedTransactions.map {
            let sum = vDSP.sum($0.map { $0.amount })
            return ValueTimeDataPoint(date: $0.first!.wrappedDate, value: sum)
        }
    }
}
