//
//  CurrencyPieChart.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct CurrencyPieChart: View {
    var values: [PieChartDataPoint]
    var backgroundColor: Color = .clear
    var showSliceLabels: Bool = false
    var centerLabel: Double
    var adjustedValues: [PieChartDataPoint] {
        if values.count < 6 {
            return values
        }
        let otherCategory = PieChartDataPoint(title: "Other", value: values[6...].map { $0.value}.reduce(0, +), color: values.last?.color ?? .clear)
        var correctValues: [PieChartDataPoint] = values[..<4].map { $0 }
        correctValues.append(otherCategory)
        return correctValues
    }
    
    var body: some View {
        let amountValues: [Double] = adjustedValues.map { $0.value }
        let colors: [Color] = adjustedValues.map { $0.color }
        GeometryReader { proxy in
            ZStack {
                PieChart(values: amountValues, colors: colors, backgroundColor: backgroundColor, showSliceLabels: showSliceLabels)
                let size = min(proxy.size.width, proxy.size.height) * 0.6
                ZStack {
                    Circle()
                        .foregroundStyle(.thinMaterial)
                    Text(centerLabel, format: .currency(code: "EUR"))
                        .font(.subheadline)
                        .padding(5)
                }
                .frame(width: size, height: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
