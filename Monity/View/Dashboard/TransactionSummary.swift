//
//  TransactionSummary.swift
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
                Text("You saved \(Int((1 - percentage) * 100))% of your income")
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
            .contextMenu {
                RenderAndShareButton(previewTitle: "Transactions") {
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

fileprivate struct TransactionCategoryTile: View {
    @StateObject private var lastYearExpenses: CategoryRetroDataPoint
    @StateObject private var lastYearIncome: CategoryRetroDataPoint
    private var category: TransactionCategory
    
    init(category: TransactionCategory) {
        self.category = category
        self._lastYearExpenses = StateObject(
            wrappedValue: CategoryRetroDataPoint(
                category: category, timeframe: .pastYear, isForExpenses: true
            )
        )
        self._lastYearIncome = StateObject(
            wrappedValue: CategoryRetroDataPoint(
                category: category, timeframe: .pastYear, isForExpenses: false
            )
        )
    }
    
    private var mainDataPoint: CategoryRetroDataPoint {
        if lastYearExpenses.total > lastYearIncome.total {
            return lastYearExpenses
        }
        return lastYearIncome
    }
    
    private var tintColor: Color {
        guard let isForExpenses = mainDataPoint.isForExpenses else {
            return .secondary
        }
        return isForExpenses ? .red : .green
    }
    
    var body: some View {
        NavigationLink(
            destination: TransactionCategoryShow(
                category: category, showExpenses: true
            )
        ) {
            HStack {
                HStack(alignment: .center, spacing: 16) {
                    if let icon = category.iconName {
                        Image(systemName: icon)
                            .frame(width: 20)
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text(category.wrappedName)
                            .fontWeight(.bold)
                        Text("\(mainDataPoint.numTransactions) transactions")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Last Year")
                        .font(.caption)
                    VStack(alignment: .trailing) {
                        Text(mainDataPoint.total, format: .customCurrency())
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text("Ø\(mainDataPoint.averagePerMonth.formatted(.customCurrency())) p.m.")
                            .font(.caption2)
                    }
                    
                }
                .tintedBackground(tintColor, backgroundOpacity: 0.05)
            }
            .padding(.vertical, 2)
        }
    }
}

fileprivate struct TransactionCategoryList: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)],
        predicate: NSPredicate(
            format: "ANY transactions.date > %@", Date.oneYearAgo as NSDate
        )
    ) private var allCategories: FetchedResults<TransactionCategory>
    
    var body: some View {
        ForEach(allCategories) { category in
            TransactionCategoryTile(category: category)
        }
    }
}


fileprivate struct TransactionSummaryPage: View {
//    @State private var showAverageBar: Bool = false
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    TransactionBarChart(
//                        isExpense: content.showingExpenses,
//                        color: content.showingExpenses ? .red : .green,
//                        showAverageBar: showAverageBar
                    )
                    .frame(minHeight: 300)
                    .padding(.bottom)
//                    Picker("", selection: $content.showingExpenses) {
//                        Text("Expenses").tag(true)
//                        Text("income.plural").tag(false)
//                    }
//                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
//            Section {
//                Toggle("Show average", isOn: $showAverageBar)
//            }
            
            Section("Categories") {
                TransactionCategoryList()
            }
        }
        .onChange(of: content.showingExpenses) { _ in
            Haptics.shared.play(.soft)
        }
        .navigationTitle("Transactions")
    }
}

struct TransactionListPerCategory: View {
    @State var showEditTransactionView: Bool = false
    @StateObject private var content: TransactionDateGroupedList
    var category: TransactionCategory
    var showExpenses: Bool?
    
    init(category: TransactionCategory, showExpenses: Bool?) {
        self._content = StateObject(
            wrappedValue: TransactionDateGroupedList(
                category: category,
                isExpense: showExpenses,
                groupingGranularity: .month
            )
        )
        self.category = category
        self.showExpenses = showExpenses
    }
    
    var body: some View {
        TransactionsList(
            showAddTransactionView: $showEditTransactionView,
            transactionsByDate: content.groupedTransactions,
            dateFormat: .dateTime.year().month()
        )
        .modifier(HackyFixVisualBugModifier())
        .searchable(text: $content.searchText)
    }
}

fileprivate struct HackyFixVisualBugModifier: ViewModifier {
    @State private var toolbarVisibility : Visibility = .hidden
    
    func body(content: Content) -> some View {
        content
            .onAppear {toolbarVisibility = .automatic}
            .toolbar(toolbarVisibility, for: .navigationBar)
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
        TransactionCategoryShow(category: c, showExpenses: true)
    }
}
