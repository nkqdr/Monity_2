//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    
    var noCategories: some View {
        VStack {
            Text("No Savings categories defined.")
            Text("Go to Settings > Savings to define your categories.")
        }
        .foregroundColor(.secondary)
        .padding()
        .multilineTextAlignment(.center)
    }
    
    var timeframePicker: some View {
        Picker("Timeframe", selection: $content.timeFrameToDisplay) {
            Text("Last Month").tag(0)
            Text("Last Year").tag(1)
            Text("5 Years").tag(2)
            Text("Max").tag(3)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    var savingsChart: some View {
        Chart(content.lineChartData) {
            LineMark(x: .value("Date", $0.date), y: .value("Net-Worth", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)
                .symbol {
                    Circle()
                        .frame(width: 8)
                }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "EUR"))
            }
        }
        .chartYScale(domain: content.minLineChartValue ... content.maxLineChartValue)
        .frame(height: 200)
        .foregroundColor(content.percentChangeInLastYear >= 0 ? .green : .red)
        .padding()
    }
    
    var scrollViewContent: some View {
        ScrollView {
            savingsChart
            timeframePicker
            Divider()
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(content.items) { category in
                    GroupBox(label: Text(category.wrappedName).groupBoxLabelTextStyle()) {
                        Circle()
                            .frame(width: 20)
                            .foregroundColor(.red)
                    }
                    .groupBoxStyle(CustomGroupBox())
                    .frame(minHeight: 200)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var mainContent: some View {
        if content.items.isEmpty {
            noCategories
        } else {
            scrollViewContent
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            mainContent
        }
        .navigationTitle("Savings Overview")
    }
}

struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Spacer()
            HStack {
                Spacer()
                configuration.content
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemGroupedBackground)))
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
