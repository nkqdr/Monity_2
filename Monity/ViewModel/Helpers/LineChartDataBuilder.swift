//
//  LineChartDataBuilder.swift
//  Monity
//
//  Created by Niklas Kuder on 01.11.23.
//

import Foundation
import Accelerate

class LineChartDataBuilder {
    static func generateSavingsLineChartData(for entries: [SavingsEntry], granularity: Calendar.Component = .day, allowAnimation: Bool = true) -> [ValueTimeDataPoint] {
        let categories: Set<SavingsCategory> = Set(entries.map(\.category!))
        let calendar = Calendar.current
        
        guard entries.count > 0 else {
            return []
        }
        
        let sortedEntries = entries.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
        
        var dataPoints: [ValueTimeDataPoint] = []
        
        var currentDate: Date = calendar.dateInterval(of: granularity, for: sortedEntries.first!.wrappedDate)!.end.addingTimeInterval(-1)
        var currentEntries: [SavingsCategory: SavingsEntry] = [:]
        
        for category in categories {
            currentEntries[category] = category.lastEntryBefore(currentDate)
        }
        
        for entry in sortedEntries {
            guard let _ = entry.category else {
                continue
            }
            
            let isInCurrentDP = calendar.isDate(entry.wrappedDate, equalTo: currentDate, toGranularity: granularity)
            if !isInCurrentDP {
                dataPoints.append(
                    ValueTimeDataPoint(
                        date: currentDate,
                        value: vDSP.sum(currentEntries.map { $1.amount }),
                        animate: !allowAnimation
                    )
                )
                let endOfNextInterval = calendar.dateInterval(of: granularity, for: entry.wrappedDate)!.end.addingTimeInterval(-1)
                currentDate = min(entry.wrappedDate, endOfNextInterval)
            }
            currentEntries[entry.category!] = entry
        }
        dataPoints.append(
            ValueTimeDataPoint(
                date: currentDate,
                value: vDSP.sum(currentEntries.map { $1.amount }),
                animate: !allowAnimation
            )
        )
        return dataPoints
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
