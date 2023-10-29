//
//  EOY_Review.swift
//  Monity
//
//  Created by Niklas Kuder on 26.12.23.
//

import SwiftUI
import Charts

fileprivate struct DrawingConstants {
    static let cornerRadius: CGFloat = 15
    static let scrollViewSpacing: CGFloat = 5
    static let titleTopPaddingFactor: CGFloat = 1 / 7
}

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
                .cornerRadius(DrawingConstants.cornerRadius - 5)
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
            }
        }
        .foregroundStyle(tint)
        .frame(height: 340)
    }
}

fileprivate struct IntroView: View {
    var yearString: String
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("🎊")
                        .font(.system(size: 50))
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Text("Let's reflect on \(yearString)!").font(.title.bold())
                    Text("As we approach the end of \(yearString), it's time to reflect on your financial journey. Our End-of-Year Report offers a deep dive into your spending habits, income sources, and overall financial health. This detailed analysis isn't just numbers; it's your story of financial growth and smart choices. Let's uncover the insights that will shape your path to financial success in the upcoming year.")
                        .foregroundStyle(.secondary)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}


fileprivate struct RegisteredTransactionsView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("Year in Review:\n Your Transactional Triumphs!")
                        .font(.title.bold())
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Group {
                        Group {
                            Text(content.totalAmountOfIncomeTransactions, format: .number)
                                .font(.system(size: 35, weight: .bold)) + Text("eoy_review.transactions.1")
                        }
                        
                        Group {
                            Text(content.totalAmountOfExpenseTransactions, format: .number)
                                .font(.system(size: 35, weight: .bold)) + Text("eoy_review.transactions.2")
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                    .foregroundStyle(.secondary)
                   
                    Text("eoy_review.transactions.3")
                        .foregroundStyle(.secondary)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct MostExpensiveCategoriesView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("Cash Chronicles:\n Where Money Flows!")
                        .font(.title.bold())
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Text("These were your most expensive categories in the last year")
                        
                        .foregroundStyle(.secondary)
                    TopNChart(data: Array(content.mostExpensiveCategories.prefix(5).map {
                        TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
                    }), tint: .red.gradient)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct MostIncomeCategoriesView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("Uncover Your Cash Trails!")
                        .font(.title.bold())
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Text("This is how you got your money")
                        
                        .foregroundStyle(.secondary)
                    TopNChart(data: Array(content.mostIncomeCategories.prefix(5).map {
                        TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
                    }), tint: .green.gradient)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct IncomeVsExpenses: View {
    @EnvironmentObject var content: EOYViewModel
    @StateObject var cashFlowContent = YearlyCashflowViewModel()
    
    private var data: [IncomeExpenseData] {
        [
            IncomeExpenseData(isExpense: false, value: content.totalIncome),
            IncomeExpenseData(isExpense: true, value: content.totalExpenses)
        ]
    }
    
    @ViewBuilder
    private var barChart: some View {
        Chart(data) { dp in
            BarMark(x: .value("Type", Bundle.main.localizedString(forKey: dp.isExpense ? "Expenses" : "income.plural", value: nil, table: nil)), y: .value("Amount", dp.value))
                .foregroundStyle(dp.isExpense ? Color.red.gradient : Color.green.gradient)
                .annotation(position: .top) { _ in
                    if (dp.value != 0) {
                        Text(dp.value, format: .customCurrency())
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                .cornerRadius(DrawingConstants.cornerRadius - 5)
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
        .frame(height: 200)
    }
    
    @ViewBuilder
    private var cashFlowChart: some View {
        let minValue: Double = min(0, (cashFlowContent.data.map { $0.value }.min() ?? 10))
        let absMaxValue: Double = (cashFlowContent.data.map { abs($0.value) }.max() ?? 10)
        let lastDP: ValueTimeDataPoint? = cashFlowContent.data.last
        
        Chart(cashFlowContent.data) {
            AreaMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                .opacity(0.5)
                .interpolationMethod(.monotone)
            LineMark(x: .value("Date", $0.date), y: .value("Amount", $0.value))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.monotone)
        }
        .chartYAxis {
            AxisMarks { value in
                let currencyCode = UserDefaults.standard.string(forKey: AppStorageKeys.selectedCurrency)
                AxisGridLine()
                AxisValueLabel(format: .currency(code: currencyCode ?? "EUR"))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .chartYScale(domain: minValue ... absMaxValue)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
        .frame(height: 200)
        .foregroundStyle((lastDP != nil && lastDP!.value >= 0) ? .green : .red)
    }
    
    @ViewBuilder
    var annotatedDiff: Text {
        let diff = abs(content.totalIncome - content.totalExpenses)
        Text(diff, format: .customCurrency())
            .foregroundColor(content.totalIncome >= content.totalExpenses ? .green : .red)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("Financial Harmony:\n Income vs Expenses!")
                        .font(.title.bold())
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    
                    Group {
                        if content.totalIncome >= content.totalExpenses {
                            Text("Well done! You have earned ") + annotatedDiff + Text(" more than you have spent!")
                        } else {
                            Text("This year, you have spent ") + annotatedDiff + Text(" more than you have earned. Let's mix things up next year!")
                        }
                    }
                    .foregroundStyle(.secondary)
                    
                    barChart
                    cashFlowChart
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct ReviewProgressButtons: View {
    @EnvironmentObject var content: EOYViewModel
    @Binding var showReport: Bool
    
    var backIcon: String {
        if content.currentlyDisplayedTabIndex == 0 {
            return "xmark"
        }
        return "chevron.backward"
    }
    
    var forwardIcon: String {
        if (content.currentlyDisplayedTabIndex == 4) {
            return "checkmark"
        }
        return "chevron.forward"
    }
    
    private func playHaptics() {
        Haptics.shared.play(.medium)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if 0 < content.currentlyDisplayedTabIndex && content.currentlyDisplayedTabIndex < 4 {
                    Button(role: .destructive) {
                        playHaptics()
                        showReport.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(5)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())
                    .padding()
                    .padding(.top, 5)
                }
            }
            Spacer()
            HStack {
                Button(role: content.currentlyDisplayedTabIndex == 0 ? .destructive : .cancel) {
                    withAnimation {
                        if content.currentlyDisplayedTabIndex <= 0 {
                            showReport.toggle()
                            playHaptics()
                        } else {
                            content.currentlyDisplayedTabIndex -= 1
                        }
                    }
                } label: {
                    Image(systemName: backIcon)
                        .padding(5)
                }
                .buttonStyle(.bordered)
                Spacer()
                Button {
                    withAnimation {
                        if content.currentlyDisplayedTabIndex >= 4 {
                            showReport.toggle()
                            playHaptics()
                        } else {
                            content.currentlyDisplayedTabIndex += 1
                        }
                    }
                } label: {
                    Image(systemName: forwardIcon)
                        .padding(5)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 8)
        }
        .onChange(of: content.currentlyDisplayedTabIndex) { _ in
            playHaptics()
        }
    }
}

fileprivate struct EOY_DetailView: View {
    @StateObject private var content = EOYViewModel()
    @Binding var showReport: Bool
    var yearString: String
   
    var body: some View {
        ZStack {
            TabView(selection: $content.currentlyDisplayedTabIndex) {
                IntroView(yearString: yearString)
                    .tag(0)
                RegisteredTransactionsView()
                    .tag(1)
                MostExpensiveCategoriesView()
                    .tag(2)
                MostIncomeCategoriesView()
                    .tag(3)
                IncomeVsExpenses()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            ReviewProgressButtons(showReport: $showReport)
        }
        .environmentObject(content)
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
        HStack {
            Text("🎉").font(.system(size: 35))
            VStack(alignment: .leading) {
                HStack {
                    Group {
                        Text(Date(), format: .dateTime.year()) +
                        Text(" is coming to an end")
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
        .background(Color.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 5)
        .sheet(isPresented: $showReport) {
            EOY_DetailView(showReport: $showReport, yearString: Date().formatted(.dateTime.year()))
        }
        .onTapGesture {
            showReport.toggle()
        }
    }
}

#Preview {
    EOY_DetailView(showReport: .constant(true), yearString: Date().formatted(.dateTime.year()))
//    EOY_ReviewTile()
//    .preferredColorScheme(.dark)
}
