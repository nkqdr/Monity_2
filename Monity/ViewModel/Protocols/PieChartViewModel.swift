//
//  PieChartViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import Foundation
import SwiftUI

protocol PieChartViewModel {
    func getPieChartDataPoints(for transactions: [Transaction], with color: Color) -> [PieChartDataPoint]
}

extension PieChartViewModel {
    func getPieChartDataPoints(for transactions: [Transaction], with color: Color) -> [PieChartDataPoint] {
        var byCategory: [String?:Double] = [:]
        let usedCategoryNames: Set<String?> = Set(transactions.map { $0.category?.name })
        for usedCategoryName in usedCategoryNames {
            byCategory[usedCategoryName] = transactions.filter { $0.category?.name == usedCategoryName }.map { $0.amount }.reduce(0, +)
        }
        var dps: [PieChartDataPoint] = []
        let sorted = byCategory.keys.sorted(by: {(first, second) in
            return byCategory[first]! > byCategory[second]!
        })
        let totalDataPoints: Double = Double(sorted.count)
        for (index, categoryName) in sorted.enumerated() {
            let opacity: Double = 1.0 - (Double(index) / totalDataPoints)
            dps.append(PieChartDataPoint(title: categoryName ?? "No category", value: byCategory[categoryName] ?? 0, color: color.opacity(opacity)))
        }
        return dps
    }
}
