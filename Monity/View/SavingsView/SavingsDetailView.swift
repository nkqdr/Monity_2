//
//  SavingsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI
import Charts

struct SavingsDetailView: View {
    @State private var showHiddenCategories: Bool = false
    @State private var showAssetAllocation: Bool = false
    @State private var showAddEntrySheet: Bool = false
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
    
    @ViewBuilder
    func savingsCategorySummaryTile(_ category: SavingsCategory) -> some View {
        let label = VStack(alignment: .leading) {
            Text(category.wrappedName).groupBoxLabelTextStyle()
            Text(category.lastEntry?.amount.formatted(.customCurrency()) ?? "-")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        let dataPoints: [ValueTimeDataPoint] = category.lineChartDataPoints(after: content.lowerBoundDate)
        let maxValue: Double = dataPoints.map { $0.value }.max() ?? 0
        GroupBox(label: label) {
            Chart(dataPoints) {
                AreaMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                    .opacity(0.5)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Date", $0.date), y: .value("Value", $0.value))
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .chartYScale(domain: 0 ... maxValue)
            .foregroundColor(category.lastEntry?.amount ?? 0 >= 0 ? .green : .red)
        }
        .groupBoxStyle(CustomGroupBox())
        .frame(minHeight: 200)
    }
    
    var categorySectionHeader: some View {
        HStack {
            Text("Categories")
                .textCase(.uppercase)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                showAddEntrySheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal)
    }
    
    var scrollViewContent: some View {
        ScrollView {
            SavingsLineChart()
            SavingsProjections()
            categorySectionHeader
                .padding(.horizontal)
                .padding(.top)
            SavingsCategoryList(categories: content.shownCategories)
        }
    }
    
    @ViewBuilder
    var hiddenCategoriesSheet: some View {
        NavigationView {
            ListBase {
                ScrollView {
                    SavingsCategoryList(categories: content.hiddenCategories)
                }
            }
            .navigationTitle("Hidden Categories")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    var assetAllocationSheet: some View {
        NavigationView {
            AssetAllocationPieChart(relevantLabels: SavingsCategoryLabel.allCasesWithoutNone)
                .navigationTitle("Asset Allocation")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var body: some View {
        ListBase {
            if content.items.isEmpty {
                noCategories
            } else {
                scrollViewContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showHiddenCategories.toggle() } label: {
                        Label("Hidden Categories", systemImage: "eye.slash.fill")
                    }
                    Button { showAssetAllocation.toggle() } label: {
                        Label("Asset Allocation", systemImage: "chart.pie.fill")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showHiddenCategories) {
            hiddenCategoriesSheet
        }
        .sheet(isPresented: $showAssetAllocation) {
            assetAllocationSheet
        }
        .sheet(isPresented: $showAddEntrySheet) {
            SavingsEntryFormView(isPresented: $showAddEntrySheet, editor: SavingsEditor(entry: nil))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .navigationTitle("Savings Overview")
    }
}

struct WealthView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsDetailView()
    }
}
