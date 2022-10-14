//
//  CurrentMonthDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct CurrentMonthDetailView: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @StateObject private var content = MonthlyOverviewViewModel()
    
    var overviewHeader: some View {
        VStack(alignment: .leading) {
//            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("Days left:")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(content.remainingDays)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("Budget:")
                            .font(.system(size: 18, weight: .semibold))
                        Text(remainingAmount, format: .currency(code: "EUR"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(remainingAmount >= 0 ? .green : .red)
                    }
                }
                Spacer()
                budgetBattery
            }
            Divider()
            HStack {
                Text("Predicted total expenses:")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text(content.predictedTotalSpendings, format: .currency(code: "EUR"))
                    .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
            }
        }
        .padding(.vertical, 5)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var budgetBattery: some View {
        let remainingPercentage: Double = (1 - content.spentThisMonth / monthlyLimit)
        let batteryColor: Color = remainingPercentage > 0.1 ? .green : .red
        let remainingBatteryHeight: Double = remainingPercentage > 0 ? 120 * remainingPercentage : 0
        let textColor: Color? = remainingPercentage > 0 ? nil : .red
        ZStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial, strokeBorder: batteryColor.opacity(0.2))
                    .frame(width: 70, height: 120)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 70, height: remainingBatteryHeight)
                    .foregroundStyle(batteryColor.gradient)
            }
            Text(String(format: "%.1f", 100 * remainingPercentage) + "%")
                .fontWeight(.bold)
                .foregroundColor(textColor)
        }
    }
    
    private func legend(dps: [PieChartDataPoint]) -> some View {
        VStack(alignment: .leading) {
            ForEach(dps) { dataPoint in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(dataPoint.color)
                    VStack(alignment: .leading) {
                        Text(dataPoint.title)
                            .font(.subheadline)
                        Text(dataPoint.value, format: .currency(code: "EUR"))
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                overviewHeader
            }
            Section(header: Text("Income")) {
                HStack {
                    legend(dps: content.incomeDataPoints)
                    Spacer()
                    CurrencyPieChart(values: content.incomeDataPoints, backgroundColor: .clear, centerLabel: content.earnedThisMonth)
                        .frame(maxHeight: 150)
                }
                .frame(maxHeight: 177)
            }
            Section(header: Text("Expenses")) {
                HStack {
                    legend(dps: content.expenseDataPoints)
                    Spacer()
                    CurrencyPieChart(values: content.expenseDataPoints, backgroundColor: .clear, centerLabel: content.spentThisMonth)
                        .frame(maxHeight: 150)
                }
                .frame(maxHeight: 177)
            }
            Section(header: Text("Cashflow")) {
                Text("To-Do")
            }
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
        .navigationTitle("Monthly overview")
    }
}

struct CurrentMonthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMonthDetailView()
    }
}
