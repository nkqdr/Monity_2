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
    
    func barChartHeader(timeframe: String, value: Double) -> some View {
        VStack(alignment: .leading) {
            Text(timeframe)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value, format: .currency(code: "EUR"))
                .font(.headline.bold())
                .foregroundColor(.primary)
        }
    }
    
    @ViewBuilder
    var correctBarChartHeader: some View {
        if let selectedElement {
            barChartHeader(timeframe: selectedElement.date.formatted(.dateTime.year().month()), value: selectedElement.value)
        } else {
            barChartHeader(timeframe: "Total", value: totalText)
        }
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Over the last year").groupBoxLabelTextStyle(.secondary)
                Picker("", selection: $showExpenseChart) {
                    Text("Expenses").tag(true)
                    Text("Income").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: showExpenseChart) { _ in
                    selectedElement = nil
                }
                ZStack(alignment: .topLeading) {
                    correctBarChartHeader
                    if showExpenseChart {
                        expenseBarChart
                    } else {
                        incomeBarChart
                    }
                }
            }
            .listRowBackground(Color.clear)
            Section {
                if let selectedElement {
                    NavigationLink("View month summary") {
                        MonthSummaryView(monthDate: selectedElement.date)
                    }
                }
                Toggle("Show average mark", isOn: $showAverageBar)
            }
            Text("Categories").groupBoxLabelTextStyle(.secondary)
                .padding(.top)
            ForEach(retroDataPoints) { dataPoint in
                CategorySummaryTile(dataPoint: dataPoint)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Transaction Overview")
    }
}

struct AverageExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AverageExpenseDetailView()
    }
}
