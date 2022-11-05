//
//  AssetAllocationPieChart.swift
//  Monity
//
//  Created by Niklas Kuder on 05.11.22.
//

import SwiftUI
import Charts

struct AssetAllocationPieChart: View {
    @State private var activeIndex: Int = -1
    @State private var showHelpAlert: Bool = false
    @ObservedObject private var content = SavingsCategoryViewModel.shared
    var relevantLabels: [SavingsCategoryLabel]
    
    init(relevantLabels: [SavingsCategoryLabel]) {
        self.relevantLabels = relevantLabels
    }
    
    private var labelHeader: some View {
        HStack {
            ForEach(relevantLabels.indices, id: \.self) { index in
                let label = relevantLabels[index]
                HStack {
                    Circle()
                        .foregroundColor(label.color)
                        .frame(height: 20)
                    Text(LocalizedStringKey(label.rawValue))
                        .font(.headline.bold())
                        .foregroundColor(activeIndex == index ? nil : .secondary)
                        .animation(.easeInOut, value: activeIndex)
                }
                if index < relevantLabels.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.vertical)
    }
    
    private var pieChart: some View {
        GeometryReader { proxy in
            ZStack {
                PieChart(
                    values: relevantLabels.map { content.getTotalSumFor($0) },
                    colors: relevantLabels.map { $0.color },
                    showSliceLabels: true,
                    labelStyle: CustomLabelStyle(),
                    activeIndex: $activeIndex
                )
                let size = min(proxy.size.width, proxy.size.height) * 0.4
                Circle()
                    .foregroundStyle(.thickMaterial)
                    .frame(width: size)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxHeight: 300)
        .padding(.vertical)
    }
    
    private var categoryBoxLabel: some View {
        HStack {
            Text(LocalizedStringKey(relevantLabels[activeIndex].rawValue))
            Spacer()
            Text(content.getTotalSumFor(relevantLabels[activeIndex]), format: .customCurrency())
                .foregroundColor(.green)
                .font(.headline.bold())
                .padding(.leading)
        }
    }
    
    @ViewBuilder
    private var categoryBox: some View {
        let dps = content.getAssetAllocationDatapointsFor(relevantLabels[activeIndex])
        GroupBox(label: categoryBoxLabel) {
            Chart(dps) { dp in
                BarMark(x: .value("Amount", dp.totalAmount), y: .value("Category", dp.category.wrappedName))
                    .foregroundStyle(relevantLabels[activeIndex].color.gradient)
                    .annotation(position: .trailing) { _ in
                        HStack(spacing: 0) {
                            Group {
                                Text(dp.totalAmount, format: .customCurrency())
                                Text(" (" + String(format: "%.0f%%", dp.relativeAmount * 100) + ")")
                            }
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        }
                    }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    let currencyCode = UserDefaults.standard.string(forKey: "user_selected_currency")
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
                }
            }
            .frame(height: CGFloat(dps.count) * 60 + 10)
        }
        .padding(.vertical)
    }
    
    private var emptyBox: some View {
        GroupBox {
            Text("Tap the chart for more details.")
                .font(.footnote)
                .padding(.vertical)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
    }
    
    var body: some View {
        ScrollView {
            Group {
                labelHeader
                pieChart
                if activeIndex >= 0 {
                    categoryBox
                } else {
                    emptyBox
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showHelpAlert.toggle() } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
            }
        }
        .alert("Help", isPresented: $showHelpAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("asset.allocation.help.message")
        }
    }
    
    private struct CustomLabelStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title3.bold())
        }
    }
}

struct AssetAllocationPieChart_Previews: PreviewProvider {
    static var previews: some View {
        AssetAllocationPieChart(relevantLabels: SavingsCategoryLabel.allCasesWithoutNone)
    }
}
