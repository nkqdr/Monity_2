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
    @State private var showExpenseChart: Bool = true
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    var expenseBarChart: some View {
        LargeValuePerMonthChart(selectedElement: $selectedElement, valuePerMonthDataPoints: content.monthlyExpenseDataPoints, showAverageBar: showAverageBar, average: content.averageExpenses, color: .red)
            .padding(.vertical)
    }
    
    var incomeBarChart: some View {
        LargeValuePerMonthChart(selectedElement: $selectedElement, valuePerMonthDataPoints: content.monthlyIncomeDataPoints, showAverageBar: showAverageBar, average: content.averageIncome, color: .green)
            .padding(.vertical)
    }
    
    var totalText: Double {
        if showExpenseChart {
            return content.totalExpensesThisYear
        } else {
            return content.totalIncomeThisYear
        }
    }
    
    var retroDataPoints: [CategoryRetroDataPoint] {
        if showExpenseChart {
            return content.expenseCategoryRetroDataPoints
        } else {
            return content.incomeCategoryRetroDataPoints
        }
    }
    
    var timeframeString: String {
        if showExpenseChart {
            return content.monthlyExpenseDataPoints.first!.date.formatted(.dateTime.year().month()) + " - " + content.monthlyExpenseDataPoints.last!.date.formatted(.dateTime.year().month())
        } else {
            return content.monthlyIncomeDataPoints.first!.date.formatted(.dateTime.year().month()) + " - " + content.monthlyIncomeDataPoints.last!.date.formatted(.dateTime.year().month())
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
                Text(totalText, format: .customCurrency())
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
                    if showExpenseChart {
                        expenseBarChart
                    } else {
                        incomeBarChart
                    }
                }
                Picker("", selection: $showExpenseChart) {
                    Text("Expenses").tag(true)
                    Text("income.plural").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: showExpenseChart) { _ in
                    selectedElement = nil
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            Section {
                
                Toggle("Show average mark", isOn: $showAverageBar)
            }
            Section("Categories") {
                ForEach(retroDataPoints) { dataPoint in
                    NavigationLink(destination: TransactionCategorySummaryView(category: dataPoint.category, showExpenses: showExpenseChart)) {
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
