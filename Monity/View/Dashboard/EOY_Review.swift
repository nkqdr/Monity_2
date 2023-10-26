//
//  EOY_Review.swift
//  Monity
//
//  Created by Niklas Kuder on 26.12.23.
//

import SwiftUI
import Charts

fileprivate struct TopNChart<S>: View where S: ShapeStyle {
    struct DataType: Identifiable {
        var id = UUID()
        var category: TransactionCategory
        var totalAmount: Double
    }
    var data: [DataType]
    var tint: S
    
    var body: some View {
        Chart(data) {
            BarMark(x: .value("Amount", $0.totalAmount), y: .value("Category", $0.category.wrappedName))
        }
        .chartXAxis {
            AxisMarks { value in
                let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
                AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
            }
        }
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
            EmptyView()
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
            EmptyView()
        }
    }
    
    var body: some View {
        ListBase {
            ScrollView(showsIndicators: false) {
                Group {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("You have registered a total of \(content.totalAmountOfTransactions) transactions this year.")
                            Text("\(content.totalAmountOfIncomeTransactions) of these transactions were registered as income and \(content.totalAmountOfExpenseTransactions) were registered as expenses.")
                        }
                    }
                    .groupBoxStyle(CustomGroupBox())
                    
                    mostExpensiveCategories
                    
                    mostIncomeCategories
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
            header().font(.subheadline.bold())
            GroupBox {
                content()
            }
            .groupBoxStyle(CustomGroupBox())
            footer().font(.footnote).foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
}

struct EOY_ReviewTile: View {
    
    var body: some View {
        NavigationLink(destination: EOY_DetailView(yearString: Date().formatted(.dateTime.year()))) {
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
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 5)
    }
}

#Preview {
    NavigationStack {
        EOY_ReviewTile()
    }
//    .preferredColorScheme(.dark)
}
