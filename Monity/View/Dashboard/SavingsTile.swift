//
//  SavingsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI
import Charts

struct SavingsTile: View {
    @ObservedObject private var content = SavingsCategoryViewModel()
    
    @ViewBuilder
    var savingsChart: some View {
        Chart(content.filteredLineChartData) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
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
        NavigationLink(destination: SavingsDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Last Year")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
        }
        .buttonStyle(.plain)
    }
}

struct SavingsTile_Previews: PreviewProvider {
    static var previews: some View {
        SavingsTile()
    }
}
