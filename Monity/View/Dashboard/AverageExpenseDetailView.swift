//
//  AverageExpenseDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI
import Charts

struct AverageExpenseDetailView: View {
    @State private var showAverageBar: Bool = false
    @State private var selectedElement: ValueTimeDataPoint?
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    var timeframeString: String {
        if content.showingExpenses {
            return (content.monthlyExpenseDataPoints.first?.date.formatted(.dateTime.year().month()) ?? "") + " - " + (content.monthlyExpenseDataPoints.last?.date.formatted(.dateTime.year().month()) ?? "")
        } else {
            return (content.monthlyIncomeDataPoints.first?.date.formatted(.dateTime.year().month()) ?? "") + " - " + (content.monthlyIncomeDataPoints.last?.date.formatted(.dateTime.year().month()) ?? "")
        }
    }
    
    @ViewBuilder
    var correctBarChartHeader: some View {
        if let selectedElement {
            VStack(alignment: .leading) {
                Text(selectedElement.date.formatted(.dateTime.year().month()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(selectedElement.value, format: .customCurrency())
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
        } else {
            VStack(alignment: .leading) {
                Group {
                    Text(timeframeString)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                Text(content.totalValue, format: .customCurrency())
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                
            }
        }
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    correctBarChartHeader
                    LargeValuePerMonthChart(selectedElement: $selectedElement, showAverageBar: showAverageBar)
                        .padding(.vertical)
                }
                Picker("", selection: $content.showingExpenses) {
                    Text("Expenses").tag(true)
                    Text("income.plural").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: content.showingExpenses) { _ in
                    selectedElement = nil
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            Section {
                Toggle("Show average mark", isOn: $showAverageBar)
            }
            Section("Categories") {
                ForEach(content.retroDataPoints) { dataPoint in
                    NavigationLink(destination: TransactionCategorySummaryView(category: dataPoint.category, showExpenses: content.showingExpenses)) {
                        CategorySummaryTile(dataPoint: dataPoint)
                    }
                }
            }
        }
        .navigationTitle("Transaction Overview")
    }
}

struct AverageExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AverageExpenseDetailView()
    }
}
