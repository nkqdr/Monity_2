//
//  EOY_Review.swift
//  Monity
//
//  Created by Niklas Kuder on 26.12.23.
//

import SwiftUI
import Charts

fileprivate struct IncomeExpenseData: Identifiable {
    var id = UUID()
    var isExpense: Bool
    var value: Double
}

fileprivate struct TopNChart<S>: View where S: ShapeStyle {
    struct DataType: Identifiable {
        var id = UUID()
        var category: TransactionCategory
        var totalAmount: Double
    }
    var data: [DataType]
    var tint: S
    
    var body: some View {
        Chart(data) { dp in
            BarMark(x: .value("Amount", dp.totalAmount), y: .value("Category", dp.category.wrappedName))
                .annotation(position: .trailing) { _ in
                    Text(dp.totalAmount, format: .customCurrency())
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
            }
        }
        .foregroundStyle(tint)
        .frame(minHeight: 220)
    }
}

fileprivate struct EOY_DetailView: View {
    @StateObject private var content = EOYViewModel()
    var yearString: String
    
    @ViewBuilder
    private var mostExpensiveCategories: some View {
        SummaryTile {
            TopNChart(data: Array(content.mostExpensiveCategories.prefix(3).map {
                TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
            }), tint: .red.gradient)
        } header: {
            Text("Cash Chronicles: Where Money Flows!")
        } footer: {
            Text("These were your most expensive categories in the last year")
        }
    }
    
    @ViewBuilder
    private var mostIncomeCategories: some View {
        SummaryTile {
            TopNChart(data: Array(content.mostIncomeCategories.prefix(3).map {
                TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
            }), tint: .green.gradient)
        } header: {
            Text("Uncover Your Cash Trails!")
        } footer: {
            Text("This is how you got your money")
        }
    }
    
    @ViewBuilder
    private var incomeVSexpenses: some View {
        let data = [
            IncomeExpenseData(isExpense: false, value: content.totalIncome),
            IncomeExpenseData(isExpense: true, value: content.totalExpenses)
        ]
        
        SummaryTile {
            Chart(data) { dp in
                BarMark(x: .value("Type", dp.isExpense ? "Expenses" : "Income"), y: .value("Amount", dp.value))
                    .foregroundStyle(dp.isExpense ? Color.red.gradient : Color.green.gradient)
                    .annotation(position: .top) { _ in
                        Text(dp.value, format: .customCurrency())
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
            }
            .chartYAxis(.hidden)
        } header: {
            Text("Financial Harmony: Income vs Expenses!")
        } footer: {
            Group {
                if content.totalIncome > content.totalExpenses {
                    let diff = (content.totalIncome - content.totalExpenses).formatted(.customCurrency())
                    Text("Well done! You have earned \(diff) more than you have spent!")
                } else {
                    let diff = (content.totalExpenses - content.totalIncome).formatted(.customCurrency())
                    Text("This year, you have spent \(diff) more than you have earned. Let's mix things up next year!")
                }
            }
        }
    }
    
    @ViewBuilder
    private var introBox: some View {
        GroupBox(label: Text("🎊Let's reflect on \(yearString)!🎊").groupBoxLabelTextStyle(.primary)) {
            Text("As we approach the end of \(yearString), it's time to reflect on your financial journey. Our End-of-Year Report offers a deep dive into your spending habits, income sources, and overall financial health. This detailed analysis isn't just numbers; it's your story of financial growth and smart choices. Let's uncover the insights that will shape your path to financial success in the upcoming year.").foregroundStyle(.secondary)
        }
        .groupBoxStyle(CustomGroupBox())
    }
    
    var body: some View {
        ListBase {
            ScrollView(showsIndicators: false) {
                Group {
                    introBox
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("You have registered a total of \(content.totalAmountOfTransactions) transactions this year.")
                            Text("\(content.totalAmountOfIncomeTransactions) of these transactions were registered as income and \(content.totalAmountOfExpenseTransactions) were registered as expenses.")
                        }
                    }
                    .groupBoxStyle(CustomGroupBox())
                    
                    mostExpensiveCategories
                    mostIncomeCategories
                    incomeVSexpenses
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(yearString) Review")
        .navigationBarTitleDisplayMode(.large)
    }
}

fileprivate struct SummaryTile<H, C, F> : View where H: View, C: View, F: View {
    var content: () -> C
    var header: () -> H
    var footer: () -> F
    
    init(content: @escaping () -> C, header: @escaping () -> H, footer: @escaping () -> F) {
        self.content = content
        self.header = header
        self.footer = footer
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header().font(.headline.bold()).padding(.horizontal)
            GroupBox {
                content()
            }
            .groupBoxStyle(CustomGroupBox())
            footer().font(.footnote).foregroundColor(.secondary).padding(.horizontal)
        }
        .padding(.top, 20)
    }
}

struct EOY_ReviewTile: View {
    @State private var showReport: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    Text("🎊") +
                    Text(Date(), format: .dateTime.year()) +
                    Text(" is coming to an end 🎊")
                }
                .font(.headline.bold())
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.top, 4)
            }
            Text("Your Financial Year at a Glance")
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 5)
        .sheet(isPresented: $showReport) {
            EOY_DetailView(yearString: Date().formatted(.dateTime.year()))
        }
        .onTapGesture {
            showReport.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        EOY_ReviewTile()
    }
//    .preferredColorScheme(.dark)
}
