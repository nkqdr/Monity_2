//
//  LineChartDataBuilder.swift
//  Monity
//
//  Created by Niklas Kuder on 01.11.23.
//

import Foundation
import Accelerate

class LineChartDataBuilder {
    static func generateSavingsLineChartData(for entries: [SavingsEntry], granularity: Calendar.Component = .day) -> [ValueTimeDataPoint] {
        let uniqueDates: Set<Date> = Set(entries.map { $0.wrappedDate })
        let calendar = Calendar.current
        let granularityDates: Set<DateInterval> = Set(uniqueDates.map { calendar.dateInterval(of: granularity, for: $0)! })
        let categories: Set<SavingsCategory> = Set(entries.map(\.category!))
        
        var dpDict: [Date: Double] = [:]
        for interval in granularityDates {
            dpDict[min(interval.end, Date())] = vDSP.sum(categories.map { $0.lastEntryBefore(interval.end) }.map { $0?.amount ?? 0})
        }

        var data = dpDict.map { (key, val) in
            return ValueTimeDataPoint(date: key, value: val)
        }.sorted {
            $0.date < $1.date
        }
        if [.month].contains(where: { $0 == granularity}) {
            data.removeLast()
        }
        return data
    }
    
    static func generateCashflowData(for transactions: [AbstractTransaction], initialDate: Date? = nil) -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        
        guard !transactions.isEmpty else {
            return []
        }
        
        let sortedTransactions = transactions.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
        
        var currentDate: Date
        if let initialDate {
            currentDate = initialDate
        } else {
            currentDate = transactions.first!.wrappedDate
        }
        
        var currentAmount: Double = 0
        for transaction in sortedTransactions {
            if !transaction.wrappedDate.isSameDayAs(currentDate) {
                dataPoints.append(ValueTimeDataPoint(date: currentDate, value: currentAmount))
                currentDate = transaction.wrappedDate
            }
            
            if transaction.isExpense {
                currentAmount -= transaction.amount
            } else {
                currentAmount += transaction.amount
            }
        }
        dataPoints.append(ValueTimeDataPoint(date: currentDate, value: currentAmount))
        return dataPoints
    }
}
