//
//  IncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct PieChartDataPoint: Identifiable {
    var id: UUID = UUID()
    var title: String
    var value: Double
    var color: Color
}

struct IncomeTile: View {
    @State private var timeframe: String = ""
    let values: [Double] = [108.42, 95.12, 48.01, 50.1, 85.02, 42.01]
    let colors: [Color] = [.green, .green.opacity(0.8), .green.opacity(0.6), .green.opacity(0.4), .green.opacity(0.2), .green.opacity(0.1)]
    
    var dataPoints: [PieChartDataPoint] {
        var dps: [PieChartDataPoint] = []
        for (index, color) in colors.enumerated() {
            dps.append(PieChartDataPoint(title: "Category \(index)", value: values[index], color: color))
        }
        return dps
    }
    
    var legend: some View {
        VStack(alignment: .leading) {
            ForEach(dataPoints) { dataPoint in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(dataPoint.color)
                    Text(dataPoint.title)
                        .font(.subheadline)
                }
            }
        }
    }
    
    var body: some View {
        DashboardBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Income")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Timeframe", selection: $timeframe) {
                        Text("This month").tag("this-month")
                        Text("This year").tag("this-year")
                    }
                }
                Spacer()
                HStack {
                    legend
                    Spacer()
                    CurrencyPieChart(values: values, colors: colors, backgroundColor: .clear, centerLabel: 5221.45)
                }
            }
            .padding()
        }
        .contextMenu { contextMenu } preview: {
            Text("Preview")
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            // Do nothing because contextMenu closes automatically
        } label: {
            Label("Hide", systemImage: "eye.slash.fill")
        }
    }
}

struct IncomeTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
