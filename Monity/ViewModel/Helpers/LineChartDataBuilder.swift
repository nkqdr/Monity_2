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
}
