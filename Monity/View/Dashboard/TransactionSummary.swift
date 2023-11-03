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

fileprivate struct TransactionOverviewChart: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    var showAverageBar: Bool
    
    var body: some View {
        ExpenseBarChartWithHeader(
            data: content.barChartDataPoints,
            showAverageBar: showAverageBar,
            color: content.showingExpenses ? .red : .green
        )
    }
}


fileprivate struct TransactionSummaryPage: View {
    @State private var showAverageBar: Bool = false
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    TransactionOverviewChart(
                        showAverageBar: showAverageBar
                    )
                    .frame(minHeight: 250)
                    .padding(.bottom)
                    Picker("", selection: $content.showingExpenses) {
                        Text("Expenses").tag(true)
                        Text("income.plural").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Section {
                Toggle("Show average", isOn: $showAverageBar)
            }
            
            Section("Categories") {
                ForEach(content.retroDataPoints) { dataPoint in
                    TransactionCategorySummaryTile(dataPoint: dataPoint, showExpenses: content.showingExpenses)
                }
            }
        }
        .onChange(of: content.showingExpenses) { _ in
            Haptics.shared.play(.soft)
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
                if let icon = dataPoint.category.iconName {
                    Image(systemName: icon)
                        .frame(width: 40)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading) {
                    Text(dataPoint.category.wrappedName)
                        .fontWeight(.bold)
                    Text("\(dataPoint.numTransactions) transactions")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Last Year")
                        .font(.caption)
                    Text(dataPoint.total, format: .customCurrency())
                        .fontWeight(.semibold)
                    Text("Ø\(dataPoint.average.formatted(.customCurrency())) p.m.")
                        .font(.caption2)
                }
                .foregroundColor(Color.secondary)
            }
            .padding(.vertical, 2)
        }
        .listRowInsets(dataPoint.category.iconName != nil ? EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 16) : nil)
    }
}

struct TransactionListPerCategory: View {
    @State var showEditTransactionView: Bool = false
    @StateObject private var content: TransactionListPerCategoryViewModel
    var category: TransactionCategory
    var showExpenses: Bool?
    
    init(category: TransactionCategory, showExpenses: Bool?) {
        self._content = StateObject(wrappedValue: TransactionListPerCategoryViewModel(category: category, showExpenses: showExpenses))
        self.category = category
        self.showExpenses = showExpenses
    }
    
    var body: some View {
        TransactionsList(showAddTransactionView: $showEditTransactionView, transactionsByDate: content.transactionsByDate, dateFormat: .dateTime.year().month())
    }
}

fileprivate struct TransactionCategorySummaryView: View {
    @StateObject private var content: TransactionCategorySummaryViewModel
    var category: TransactionCategory
    var showExpenses: Bool
    
    var color: Color {
        showExpenses ? .red : .green
    }
    
    init(category: TransactionCategory, showExpenses: Bool) {
        self._content = StateObject(wrappedValue: TransactionCategorySummaryViewModel(category: category, showExpenses: showExpenses))
        self.category = category
        self.showExpenses = showExpenses
    }
    
    var body: some View {
        List {
            VStack {
                ExpenseBarChartWithHeader(data: content.dataPoints, color: color)
                    .frame(minHeight: 250)
                    .padding(.bottom)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section {
                HStack {
                    Text("Total").foregroundStyle(.secondary)
                    Spacer()
                    Text(content.retroDP.total, format: .customCurrency())
                }
                HStack {
                    Text("Average per month").foregroundStyle(.secondary)
                    Spacer()
                    Text(content.retroDP.average, format: .customCurrency())
                }
            } header: {
                Text("All-Time")
            } footer: {
                Text("These values are calculated with all entries you have ever entered")
            }
            
            Section {
                HStack {
                    Text("Total").foregroundStyle(.secondary)
                    Spacer()
                    Text(content.lastYearRetroDP.total, format: .customCurrency())
                }
                HStack {
                    Text("Average per month").foregroundStyle(.secondary)
                    Spacer()
                    Text(content.lastYearRetroDP.average, format: .customCurrency())
                }
            } header: {
                Text("Last Year")
            } footer: {
                Text("These values are calculated with all entries you have entered within the last 12 months")
            }
            
            Section {
                NavigationLink("All transactions", destination: TransactionListPerCategory(category: category, showExpenses: showExpenses).navigationBarTitleDisplayMode(.inline))
            }
        }
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
