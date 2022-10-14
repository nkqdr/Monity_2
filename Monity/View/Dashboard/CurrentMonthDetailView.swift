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
    
    var body: some View {
        List {
            Section {
                overviewHeader
            }
            Section(header: Text("Income")) {
                CurrencyPieChart(values: content.incomeDataPoints, backgroundColor: .clear, centerLabel: content.earnedThisMonth)
            }
            Section(header: Text("Expenses")) {
                CurrencyPieChart(values: content.expenseDataPoints, backgroundColor: .clear, centerLabel: content.spentThisMonth)
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
        .navigationTitle("Month Overview")
    }
}

struct CurrentMonthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMonthDetailView()
    }
}
