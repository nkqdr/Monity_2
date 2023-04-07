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
    @ObservedObject private var content = MonthlyOverviewViewModel.shared
    
    var overviewHeader: some View {
        VStack(alignment: .leading) {
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
                        Text(remainingAmount, format: .customCurrency())
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(remainingAmount >= 0 ? .green : .red)
                    }
                }
                Spacer()
                BudgetBattery()
            }
            Divider()
            HStack {
                Text("Predicted total expenses:")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(content.predictedTotalSpendings, format: .customCurrency())
                    .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
            }
            Divider()
            HStack {
                Text("Average daily expenses:")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(content.spendingsPerDay, format: .customCurrency())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
    
    var body: some View {
        ListBase {
            ScrollView {
                overviewHeader
                Group {
                    IncomeGroupBox()
                    ExpensesGroupBox()
                    CashflowChartGroupBox()
                }
                .groupBoxStyle(CustomGroupBox())
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
        .navigationTitle("Current Month")
    }
}

struct CurrentMonthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMonthDetailView()
    }
}
