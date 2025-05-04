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
        case expense, income
        
        var transactionFilter: (AbstractTransaction) -> Bool {
            switch self {
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
        category: TransactionCategory? = nil,
        now: Date = Date()
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
            self.data = TimeSeriesTransactionData.padded(
                TimeSeriesTransactionData.groupByYearMonth(data: filteredTransactions)
            )
        }
    }
    
    private static func padded(_ data: Data) -> Data {
        guard !data.isEmpty else { return data }
        let calendar = Calendar.current

        // Use first and last dates as range boundaries
        let startComponents = calendar.dateComponents([.year, .month], from: data.first!.date)
        let endComponents = calendar.dateComponents([.year, .month], from: data.last!.date)

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else {
            return data
        }

        // Convert data into a lookup dictionary with just (year, month) keys
        let dataDict = Dictionary(
            uniqueKeysWithValues: data.map {
                let comps = calendar.dateComponents([.year, .month], from: $0.date)
                return (YearMonth(year: comps.year!, month: comps.month!), $0.value)
            }
        )

        var result: Data = []
        var currentDate = startDate

        while currentDate <= endDate {
            let comps = calendar.dateComponents([.year, .month], from: currentDate)
            let key = YearMonth(year: comps.year!, month: comps.month!)
            let value = dataDict[key] ?? 0.0
            result.append(DataPoint(date: currentDate, value: value))

            // Move to next month
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }

        return result
    }
    
    private static func groupByYearMonth(data: [AbstractTransaction]) -> Data {
        var grouped = [YearMonth: Double]()

        for transaction in data {
            let components = Calendar.current.dateComponents([.year, .month], from: transaction.wrappedDate)
            guard let year = components.year, let month = components.month else { continue }
            let key = YearMonth(year: year, month: month)
            grouped[key, default: 0] += transaction.amount
        }

        let sortedKeys = grouped.keys.sorted {
            $0.year != $1.year ? $0.year < $1.year : $0.month < $1.month
        }

        return sortedKeys.map { key in
            let date = Calendar.current.date(from: DateComponents(year: key.year, month: key.month))!
            return DataPoint(date: date, value: grouped[key]!)
        }
    }
}
