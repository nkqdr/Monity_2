//
//  AverageOneYearBarChart.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI
import Charts

struct AverageOneYearBarChart: View {
    var data: [ValueTimeDataPoint]
    var average: Double
    var tint: Color = .blue
    
    var body: some View {
        Chart(data) {
            RuleMark(y: .value("Average", average))
                .foregroundStyle(tint)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .annotation(position: .top, alignment: .leading) {
                    Text("Ø")
                        .font(.footnote)
                        .foregroundColor(tint)
                }
            BarMark(x: .value("Month", $0.date, unit: .month), y: .value("Expenses", $0.value))
                .foregroundStyle(tint.opacity(0.3))
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .frame(minHeight: 110)
    }
}
