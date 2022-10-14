//
//  IncomeTileViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import SwiftUI

class IncomeTileViewModel: ObservableObject {
    @Published var timeframe: String = "this-month"
    @Published var sumInTimeframe: Double = 5226.71
    @Published var values: [Double] = [108.42, 95.12, 48.01, 50.1, 85.02, 42.01]
    
    var dataPoints: [PieChartDataPoint] {
        var dps: [PieChartDataPoint] = []
        for (index, color) in colors.enumerated() {
            dps.append(PieChartDataPoint(title: "Category \(index)", value: values[index], color: color))
        }
        return dps
    }
    let colors: [Color] = [.green, .green.opacity(0.8), .green.opacity(0.6), .green.opacity(0.4), .green.opacity(0.2), .green.opacity(0.1)]
}

struct PieChartDataPoint: Identifiable {
    var id: UUID = UUID()
    var title: String
    var value: Double
    var color: Color
}
