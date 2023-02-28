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
    var emptyString: LocalizedStringKey = "No registered transactions for this month."
    @State private var activeIndex: Int = -1
    
    var adjustedValues: [PieChartDataPoint] {
        if values.count <= DrawingConstants.maxCategories {
            return values
        }
        let remainingAmount: Double = values[(DrawingConstants.maxCategories-1)...].map { $0.value}.reduce(0, +)
        let otherCategory = PieChartDataPoint(title: "Other", value: remainingAmount, color: values[DrawingConstants.maxCategories-1].color)
        var correctValues: [PieChartDataPoint] = values[..<(DrawingConstants.maxCategories-1)].map { $0 }
        correctValues.append(otherCategory)
        return correctValues
    }
    
    private var legend: some View {
        VStack(alignment: .leading) {
            ForEach(adjustedValues) { dataPoint in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(dataPoint.color)
                    VStack(alignment: .leading) {
                        Text(dataPoint.title)
                            .font(.subheadline)
                        HStack(spacing: 5) {
                            Group {
                                Text(dataPoint.value, format: .customCurrency())
                                    .font(.caption)
                                Text("(" + String(format: "%.2f", dataPoint.value / centerLabel * 100) + "%)")
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        let amountValues: [Double] = adjustedValues.map { $0.value }
        let colors: [Color] = adjustedValues.map { $0.color }
        if adjustedValues.count > 0 {
            HStack {
                legend
                Spacer()
                GeometryReader { proxy in
                    ZStack {
                        PieChart(values: amountValues, colors: colors, backgroundColor: backgroundColor, showSliceLabels: showSliceLabels, activeIndex: $activeIndex)
                        let size = min(proxy.size.width, proxy.size.height) * 0.6
                        ZStack {
                            Circle()
                                .foregroundStyle(.thinMaterial)
                            VStack(spacing: 1) {
                                Group {
                                    if activeIndex == -1 {
                                        Text("Total")
                                    } else {
                                        Text(adjustedValues[activeIndex].title)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                Text(activeIndex == -1 ? centerLabel : adjustedValues[activeIndex].value, format: .customCurrency())
                                    .font(.subheadline)
                                    .padding(5)
                            }
                        }
                        .frame(width: size, height: size)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: 160)
            }
        } else {
            HStack {
                Spacer()
                Text(emptyString)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(minHeight: 100)
        }
    }
    
    private struct DrawingConstants {
        static let maxCategories: Int = .max
    }
}
