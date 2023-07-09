//
//  TransactionSummaryTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI
import Charts

struct TransactionSummaryTile: View {
    @StateObject private var content = TransactionSummaryViewModel()
    
    private var percentage: Double? {
        return content.percentageOfIncomeSpent
    }
    
    @ViewBuilder
    private var actualTile: some View {
        VStack(alignment: .leading) {
            if let percentage {
                Text("You saved \(Int((1 - percentage) * 100))% of your income.")
                    .groupBoxLabelTextStyle()
            } else {
                Text("Register your transactions to build the statistics!")
                    .groupBoxLabelTextStyle()
            }
            AverageOneYearBarChart(data: content.expenseBarChartData, average: content.averageExpenses, tint: .red)
                .padding(.horizontal, 4)
                .padding(.top, percentage != nil ? 0 : 10)
            AverageOneYearBarChart(data: content.incomeBarChartData, average: content.averageIncome, tint: .green)
                .padding(.horizontal, 4)
        }
    }
    
    var body: some View {
        NavigationLink(destination: TransactionSummaryPage()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Last Year")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
        }
        .buttonStyle(.plain)
    }
}


fileprivate struct TransactionSummaryPage: View {
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
            .animation(.none, value: timeframeString)
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
                    TransactionCategorySummaryTile(dataPoint: dataPoint, showExpenses: content.showingExpenses)
                }
            }
        }
        .navigationTitle("Transaction Overview")
    }
}

fileprivate struct TransactionCategorySummaryTile: View {
    var dataPoint: CategoryRetroDataPoint
    var showExpenses: Bool
    
    var body: some View {
        NavigationLink(destination: TransactionCategorySummaryView(category: dataPoint.category, showExpenses: showExpenses)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(dataPoint.category.wrappedName)
                        .fontWeight(.bold)
                    Text("\(dataPoint.numTransactions) transactions")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(dataPoint.total, format: .customCurrency())
                        .fontWeight(.semibold)
                    Text("Ø\(dataPoint.average.formatted(.customCurrency())) p.m.")
                        .font(.caption2)
                }
                .foregroundColor(Color.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

fileprivate struct TransactionCategorySummaryView: View {
    @State var showEditTransactionView: Bool = false
    @StateObject private var content: TransactionsCategorySummaryViewModel
    var category: TransactionCategory
    var showExpenses: Bool
    
    init(category: TransactionCategory, showExpenses: Bool) {
        self._content = StateObject(wrappedValue: TransactionsCategorySummaryViewModel(category: category, showExpenses: showExpenses))
        self.category = category
        self.showExpenses = showExpenses
    }
    
    var body: some View {
        TransactionsList(showAddTransactionView: $showEditTransactionView, transactionsByDate: content.transactionsByDate, dateFormat: .dateTime.year().month())
            .navigationTitle(category.wrappedName)
    }
}

struct TransactionSummaryView_Previews: PreviewProvider {
    static func generateData() -> TransactionCategory {
        let c = TransactionCategory(context: PersistenceController.preview.container.viewContext)
        c.name = "Test Category"
        c.id = UUID()
        let transaction = Transaction(context: PersistenceController.preview.container.viewContext)
        transaction.id = UUID()
        transaction.category = c
        transaction.isExpense = true
        transaction.date = Date()
        transaction.amount = 154.5
        return c
    }
    
    static var previews: some View {
        let c = generateData()
        TransactionCategorySummaryView(category: c, showExpenses: true)
    }
}
