//
//  CashflowViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import Foundation

protocol CashflowViewModel {
    func getCashFlowDataPoints(for transactions: [Transaction], in month: Date) -> [ValueTimeDataPoint]
}

extension CashflowViewModel {
    func getCashFlowDataPoints(for transactions: [Transaction], in month: Date = Date()) -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        let startOfMonthDate: Date = month.startOfThisMonth
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
