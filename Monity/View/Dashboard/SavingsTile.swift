//
//  SavingsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI
import Charts

struct SavingsTile: View {
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    
    @ViewBuilder
    var savingsChart: some View {
        Chart(content.lineChartData) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
//                .symbol {
//                    Circle()
//                        .frame(width: 5)
//                }
        }
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartYScale(domain: content.minLineChartValue ... content.maxLineChartValue)
        .frame(height: 120)
        .foregroundColor(content.percentChangeInLastYear >= 0 ? .green : .red)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    var actualTile: some View {
        let displayedPercentage = Int((content.percentChangeInLastYear * 100).rounded())
        
        VStack(alignment: .leading) {
            HStack {
                Text("Last Year").groupBoxLabelTextStyle(.secondary)
                Spacer()
            }
            Spacer()
            Group {
                if displayedPercentage >= 0 {
                    Text("Your wealth increased by \(displayedPercentage)%")
                } else {
                    Text("Your wealth decreased by \(-displayedPercentage)%")
                }
            }
            .groupBoxLabelTextStyle()
            savingsChart
        }
    }
    
    var body: some View {
        Section {
            NavigationLink(destination: SavingsDetailView()) {
                actualTile
            }
        }
    }
}

struct SavingsTile_Previews: PreviewProvider {
    static var previews: some View {
        SavingsTile()
    }
}
