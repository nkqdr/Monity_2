//
//  TimeSeriesData.swift
//  Monity
//
//  Created by Niklas Kuder on 30.06.24.
//

import Foundation
import Accelerate
import Combine

class TimeSeriesTransactionData: ObservableObject {
    typealias Data = [DataPoint]

    enum IncludedTransactions {
        case expense, income, all
        
        var transactionFilter: (AbstractTransaction) -> Bool {
            switch self {
            case .all:
                return { _ in true }
            case .income:
                return { t in t.isExpense == false }
            case .expense:
                return { t in t.isExpense == true }
            }
        }
    }
    struct DataPoint: Identifiable, Equatable {
        var id = UUID()
        var date: Date
        var value: Double
    }
    private struct YearMonth: Hashable {
        let year: Int
        let month: Int
    }
    
    @Published var data: Data = []
    private var include: IncludedTransactions
    private var timeframe: Timeframe
    private var category: TransactionCategory?
    
    private var transactionCancellable: AnyCancellable?
    private var abstractTransactionWrapper: AbstractTransactionWrapper
    
    init(
        include: IncludedTransactions, 
        timeframe: Timeframe,
        category: TransactionCategory? = nil
    ) {
        self.include = include
        self.timeframe = timeframe
        self.category = category
        let startDate = timeframe.startDate ?? Date()
        
        self.abstractTransactionWrapper = AbstractTransactionWrapper(
            startDate: startDate,
            category: category
        )
        let publisher = self.abstractTransactionWrapper.$wrappedTransactions.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { transactions in
            let filteredTransactions = transactions.filter(include.transactionFilter)
            self.data = TimeSeriesTransactionData.groupByYearMonth(data: filteredTransactions)
        }
    }
    
    private static func groupByYearMonth(data: [AbstractTransaction]) -> Data {
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
            DataPoint(
                date: Calendar.current.date(from: DateComponents(year: $0.year, month: $0.month))!,
                value: $0.totalAmount
            )
        }
    }
}
