//
//  SavingsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI
import Charts

fileprivate struct StaticSavingsLineChart: View {
    var dataPoints: [ValueTimeDataPoint]
    
    private var minYValue: Double {
        dataPoints.map { $0.value }.min() ?? 0
    }
    
    private var maxYValue: Double {
        dataPoints.map { $0.value }.max() ?? 0
    }
    
    var body: some View {
        Chart(dataPoints) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.monotone)
        }
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartYScale(domain: minYValue ... maxYValue)
        .frame(height: 120)
        .foregroundColor(!dataPoints.isEmpty && dataPoints.first!.value <= dataPoints.last!.value ? .green : .red)
        .padding(.vertical, 10)
    }
}

struct SavingsTile: View {
    @ObservedObject private var content = SavingsTileViewModel()
    @AppStorage(AppStorageKeys.showSavingsOnDashboard) private var showSavingsOnDashboard: Bool = true
    
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
            StaticSavingsLineChart(dataPoints: content.dataPoints)
        }
    }
    
    var body: some View {
        if showSavingsOnDashboard {
            NavigationLink(destination: SavingsDetailView()) {
                GroupBox(label: NavigationGroupBoxLabel(title: "Last Year")) {
                    actualTile
                }
                .groupBoxStyle(CustomGroupBox())
            }
            .buttonStyle(.plain)
        }
    }
}

struct SavingsTile_Previews: PreviewProvider {
    static var previews: some View {
        SavingsTile()
    }
}
