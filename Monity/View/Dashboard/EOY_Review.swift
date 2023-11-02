//
//  EOY_Review.swift
//  Monity
//
//  Created by Niklas Kuder on 26.12.23.
//

import SwiftUI
import Charts

fileprivate struct MaxTabTagKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

fileprivate extension EnvironmentValues {
    var maxTabTag: Int {
        get { self[MaxTabTagKey.self] }
        set { self[MaxTabTagKey.self] = newValue }
    }
}

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
    var yearString: String = Date().formatted(.dateTime.year())
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("🎊")
                        .font(.system(size: 50))
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Text("Let's reflect on \(yearString)!").font(.title.bold())
                    Group {
                        Text("eoy_review.intro.1") + Text("\(yearString)") + Text("eoy_review.intro.2")
                    }
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

fileprivate struct TopNExpenseCategoriesView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        TopNChart(data: Array(content.mostExpensiveCategories.prefix(5).map {
            TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
        }), tint: .red.gradient)
        .padding()
    }
}

fileprivate struct TopNIncomeCategoriesView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        TopNChart(data: Array(content.mostIncomeCategories.prefix(5).map {
            TopNChart.DataType( category: $0.category, totalAmount: $0.totalAmount)
        }), tint: .green.gradient)
        .padding()
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
                    Text("eoy_review.expenses.1")
                        
                        .foregroundStyle(.secondary)
                    TopNExpenseCategoriesView()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                }
                Spacer(minLength: 50)
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
                    Text("eoy_review.income.1")
                        .foregroundStyle(.secondary)
                    TopNIncomeCategoriesView()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct CashflowChart: View {
    @StateObject var cashFlowContent = YearlyCashflowViewModel()
    
    var body: some View {
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
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .chartYScale(domain: minValue ... absMaxValue)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
        .foregroundStyle((lastDP != nil && lastDP!.value >= 0) ? .green : .red)
    }
}

fileprivate struct IncomeExpenseDiffBarChart: View {
    @EnvironmentObject var content: EOYViewModel
    
    private var data: [IncomeExpenseData] {
        [
            IncomeExpenseData(isExpense: false, value: content.totalIncome),
            IncomeExpenseData(isExpense: true, value: content.totalExpenses)
        ]
    }
    
    var body: some View {
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
    }
}

fileprivate struct IncomeVsExpenses: View {
    @EnvironmentObject var content: EOYViewModel
    
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
                            Text("eoy_review.cashflow.increased.1") + annotatedDiff + Text("eoy_review.cashflow.increased.2")
                        } else {
                            Text("eoy_review.cashflow.decreased.1") + annotatedDiff + Text("eoy_review.cashflow.decreased.2")
                        }
                    }
                    .foregroundStyle(.secondary)
                    
                    IncomeExpenseDiffBarChart()
                        .frame(height: 200)
                    CashflowChart()
                        .frame(height: 200)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct SavingsChart: View {
    @EnvironmentObject var content: EOYViewModel
    
    var body: some View {
        SavingsDPLineChart(dataPoints: $content.savingsDataPoints, showHeader: false, showArea: true)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
    }
}

fileprivate struct SavingsReportView: View {
    @EnvironmentObject var content: EOYViewModel
    
    var savingsDiff: Double {
        if content.savingsDataPoints.isEmpty {
            return 0
        }
        return content.savingsDataPoints.last!.value - content.savingsDataPoints.first!.value
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("Your Year in Savings and Net Worth")
                        .font(.title.bold())
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Group {
                        if savingsDiff > 0 {
                            Text("eoy_review.savings.increase.1") +
                            Text(savingsDiff, format: .customCurrency()).foregroundColor(.green) +
                            Text("eoy_review.savings.increase.2")
                        } else {
                            Text("eoy_review.savings.decrease.1") +
                            Text(savingsDiff, format: .customCurrency()).foregroundColor(.red) +
                            Text("eoy_review.savings.decrease.2")
                        }
                    }
                    .foregroundStyle(.secondary)
                    SavingsChart()
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
    }
}

fileprivate struct EndOfReportView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Text("💰")
                        .font(.system(size: 50))
                        .padding(.top, proxy.size.height * DrawingConstants.titleTopPaddingFactor)
                    Text("Empowering Your\n Financial Future")
                        .font(.title.bold())
                    Text("Congratulations on your financial journey! Your diligence has unlocked valuable insights. Remember, every choice shapes your future. Stay disciplined, save wisely, and invest in your dreams. Your financial freedom starts now. Seize opportunities, make wise choices, and watch your wealth grow. Best of luck on your exciting journey ahead!")
                        .foregroundStyle(.secondary)
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
    @State private var renderedImage = Image(systemName: "photo")
    @Environment(\.displayScale) var displayScale
    @Environment(\.dismiss) var dismiss
    @Environment(\.maxTabTag) var lastTabIndex
    
    var backIcon: String {
        if content.currentlyDisplayedTabIndex == 0 {
            return "xmark"
        }
        return "chevron.backward"
    }
    
    var forwardIcon: String {
        if (content.currentlyDisplayedTabIndex == lastTabIndex) {
            return "checkmark"
        }
        return "chevron.forward"
    }
    
    private func playHaptics() {
        Haptics.shared.play(.soft)
    }
    
    @MainActor 
    private func renderImage() {
        let renderer = ImageRenderer(content: currentExportView)
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
    
    @ViewBuilder
    private var currentExportView: some View {
        Group {
            if content.currentlyDisplayedTabIndex == 2 {
                TopNExpenseCategoriesView()
            } else if content.currentlyDisplayedTabIndex == 3 {
                TopNIncomeCategoriesView()
            } else if content.currentlyDisplayedTabIndex == 4 {
                VStack(spacing: 10) {
                    IncomeExpenseDiffBarChart()
                    CashflowChart()
                }
            } else if content.currentlyDisplayedTabIndex == 5 && lastTabIndex != 5 {
                SavingsChart()
            }
        }
        .background(Color(uiColor: UIColor.systemBackground), in: RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
        .frame(width: 400, height: 400)
        .environmentObject(content)
    }
    
    var body: some View {
        let possibleScreens: [Int] = [2, 3, 4, 5]
        VStack {
            HStack {
                Spacer()
                HStack {
                    if possibleScreens.contains(where: { $0 == content.currentlyDisplayedTabIndex}) && content.currentlyDisplayedTabIndex != lastTabIndex {
                        ShareLink(
                            item: renderedImage,
                            preview: SharePreview(
                                "Monity Report",
                                image: renderedImage
                            )) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Circle())
                        .background {
                            Circle().fill(.ultraThickMaterial)
                        }
                    }
                    
                    if 0 < content.currentlyDisplayedTabIndex && content.currentlyDisplayedTabIndex < lastTabIndex {
                        Button {
                            playHaptics()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .padding(3)
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Circle())
                        .tint(.red)
                        .background {
                            Circle().fill(.ultraThickMaterial)
                        }
                    }
                }
                .padding()
                .padding(.top, 5)
            }
            Spacer()
            HStack {
                Button {
                    withAnimation {
                        if content.currentlyDisplayedTabIndex <= 0 {
                            dismiss()
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
                .tint(content.currentlyDisplayedTabIndex == 0 ? .red : nil)
                Spacer()
                Button {
                    withAnimation {
                        if content.currentlyDisplayedTabIndex >= lastTabIndex {
                            dismiss()
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
                .tint(content.currentlyDisplayedTabIndex == lastTabIndex ? .green : nil)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 8)
        }
        .onChange(of: content.currentlyDisplayedTabIndex) { _ in
            renderImage()
            playHaptics()
        }
    }
}

fileprivate struct EOY_DetailView: View {
    @StateObject var content = EOYViewModel()
   
    var body: some View {
        let showSavingsPage = content.savingsDataPoints.count > 2
        ZStack {
            TabView(selection: $content.currentlyDisplayedTabIndex) {
                IntroView()
                    .tag(0)
                RegisteredTransactionsView()
                    .tag(1)
                MostExpensiveCategoriesView()
                    .tag(2)
                MostIncomeCategoriesView()
                    .tag(3)
                IncomeVsExpenses()
                    .tag(4)
                if showSavingsPage {
                    SavingsReportView()
                        .tag(5)
                }
                EndOfReportView()
                    .tag(showSavingsPage ? 6 : 5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            ReviewProgressButtons()
        }
        .environmentObject(content)
        .environment(\.maxTabTag, showSavingsPage ? 6 : 5)
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
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 5)
        .sheet(isPresented: $showReport) {
            EOY_DetailView()
        }
        .onTapGesture {
            showReport.toggle()
        }
    }
}

#Preview {
    EOY_DetailView()
//    EOY_ReviewTile()
//    .preferredColorScheme(.dark)
}
