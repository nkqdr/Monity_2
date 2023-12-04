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
    
    private var tint: Color {
        !dataPoints.isEmpty && dataPoints.first!.value <= dataPoints.last!.value ? .green : .red
    }
    
    var body: some View {
        Chart(dataPoints) {
//            AreaMark(
//                x: .value("Date", $0.date),
//                yStart: .value("Amount", minYValue),
//                yEnd: .value("AmountEnd", $0.value)
//            )
//                .opacity(0.5)
//                .interpolationMethod(.monotone)
            RuleMark(y: .value("StartOfYear", dataPoints.first!.value))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text(dataPoints.first!.value, format: .customCurrency())
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .foregroundStyle(Color.gray)
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.monotone)
                .foregroundStyle(tint)
        }
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartYScale(domain: minYValue ... maxYValue)
        .padding(.vertical, 10)
        .frame(height: 170)
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
                .contextMenu {
                    RenderAndShareButton(previewTitle: "Savings", height: 250) {
                        VStack(alignment: .leading) {
                            Text("Last Year").groupBoxLabelTextStyle(.secondary)
                            Spacer()
                            actualTile
                        }
                        .padding()
                    }
                }
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
