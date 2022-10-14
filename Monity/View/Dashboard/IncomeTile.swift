//
//  IncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct IncomeTile: View {
    @StateObject private var content = IncomeTileViewModel()
    
    var legend: some View {
        VStack(alignment: .leading) {
            ForEach(content.dataPoints) { dataPoint in
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
        PreviewDashboardBox {
            VStack(alignment: .leading) {
                HStack {
                    Text("Income")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Timeframe", selection: $content.timeframe) {
                        Text("This month").tag("this-month")
                        Text("This year").tag("this-year")
                    }
                }
                Spacer()
                HStack {
                    legend
                    Spacer()
                    CurrencyPieChart(values: content.dataPoints, backgroundColor: .clear, centerLabel: content.sumInTimeframe)
                }
                .frame(maxHeight: 170)
            }
            .padding()
        } previewContent: {
            ScrollView {
                HStack {
                    Text("Categories:")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    Spacer(minLength: 60)
                    Text(content.timeframe)
                        .foregroundColor(.secondary)
                }
                ForEach(content.dataPoints) { dataPoint in
                    VStack(alignment: .leading) {
                        Text(dataPoint.title)
                            .font(.footnote)
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.green.gradient)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            .padding()
        }
    }
}

struct IncomeTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
