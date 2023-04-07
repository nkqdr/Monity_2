//
//  MonthCashflowCalculator.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import Foundation
import Combine

class MonthCashflowCalculator: ObservableObject {
    @Published var cashFlowData: [ValueTimeDataPoint] = []
    
    private var transactions: [AbstractTransaction] = [] {
        didSet {
            cashFlowData = getCashFlowDataPoints()
        }
    }
    private var selectedDate: Date = Date()
    private var transactionCancellable: AnyCancellable?
    
    init() {
        let transactionPublisher = AbstractTransactionWrapper(date: Date()).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { value in
            self.transactions = value
        }
    }
    
    private func getCashFlowDataPoints() -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        let startOfMonthDate: Date = selectedDate.startOfThisMonth
        
        let datesEntered: Set<Date> = Set(transactions.map { $0.date?.removeTimeStamp ?? Date() })
        if !datesEntered.contains(startOfMonthDate) {
            dataPoints.append(ValueTimeDataPoint(date: startOfMonthDate, value: 0))
        }
        for date in datesEntered {
            dataPoints.append(ValueTimeDataPoint(
                date: date,
                value: transactions.filter { $0.date?.removeTimeStamp ?? Date() <= date}.map { $0.isExpense ? -$0.amount : $0.amount}.reduce(0, +))
            )
        }
        return dataPoints.sorted {
            $0.date < $1.date
        }
    }
}
