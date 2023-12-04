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
    @ObservedObject private var viewModel = AssetAllocationViewModel()
    
    private var labelHeader: some View {
        HStack {
            ForEach(viewModel.allLabels.indices, id: \.self) { index in
                let label = viewModel.allLabels[index]
                HStack {
                    Circle()
                        .foregroundColor(label.color)
                        .frame(height: 20)
                    Text(LocalizedStringKey(label.rawValue))
                        .font(.headline.bold())
                        .foregroundColor(activeIndex == index ? nil : .secondary)
                        .animation(.easeInOut, value: activeIndex)
                }
                if index < viewModel.allLabels.count - 1 {
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
                    values: viewModel.allLabels.map { viewModel.getTotalSumFor($0) },
                    colors: viewModel.allLabels.map { $0.color },
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
            Text(LocalizedStringKey(viewModel.allLabels[activeIndex].rawValue))
            Spacer()
            Text(viewModel.getTotalSumFor(viewModel.allLabels[activeIndex]), format: .customCurrency())
                .tintedBackground(.green)
                .font(.headline.bold())
                .padding(.leading)
        }
    }
    
    @ViewBuilder
    private var categoryBox: some View {
        let dps = viewModel.getAssetAllocationDatapointsFor(viewModel.allLabels[activeIndex])
        GroupBox(label: categoryBoxLabel) {
            Chart(dps) { dp in
                BarMark(x: .value("Amount", dp.totalAmount), y: .value("Category", dp.category.wrappedName))
                    .foregroundStyle(viewModel.allLabels[activeIndex].color.gradient)
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
                    .cornerRadius(5)
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(dps.count) * 60 + 10)
        }
        .padding(.vertical)
    }
    
    private var emptyBox: some View {
        GroupBox {
            if viewModel.entriesExist {
                Text("Tap the chart for more details.")
                    .font(.footnote)
                    .padding(.vertical)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            } else {
                Text("Nothing to display here.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    var body: some View {
        ScrollView {
            Group {
                labelHeader
                if viewModel.entriesExist {
                    pieChart
                }
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
        AssetAllocationPieChart()
    }
}
