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
            HStack(alignment: .top) {
                Text("Predicted total expenses:").groupBoxLabelTextStyle()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(content.predictedTotalSpendings, format: .customCurrency())
                        .fontWeight(.bold)
                        .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
                    Group {
                        Text("∅ ") + Text(content.spendingsPerDay, format: .customCurrency()) + Text(" / Day")
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
                }
            }
            .padding(.vertical, 5)
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
