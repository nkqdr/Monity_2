//
//  CurrentMonthOverviewTile.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

struct CurrentMonthOverviewTile: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double = 0
    @State private var remainingAmount: Double = 0
    @StateObject private var content = MonthlyOverviewViewModel()
    
    @ViewBuilder
    var actualTile: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Days left:")
                        .font(.system(size: 18, weight: .semibold))
                    Text("\(content.remainingDays)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Budget:")
                        .font(.system(size: 18, weight: .semibold))
                    Text(remainingAmount, format: .currency(code: "EUR"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(remainingAmount >= 0 ? .green : .red)
                }
            }
        }
        .onChange(of: monthlyLimit) { newValue in
            remainingAmount = newValue - content.spentThisMonth
        }
        .onAppear {
            remainingAmount = monthlyLimit - content.spentThisMonth
        }
    }
    
    var body: some View {
        NavigationLink(destination: CurrentMonthDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Current Month")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
        }
        .buttonStyle(.plain)
        .onlyHideContextMenu {
            if monthlyLimit > 0 {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Predicted total expenses:")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                        Text(content.predictedTotalSpendings, format: .currency(code: "EUR"))
                            .foregroundColor(content.predictedTotalSpendings > monthlyLimit ? .red : .green)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer(minLength: 60)
                    BudgetBattery(monthlyLimit: monthlyLimit, alreadySpent: content.spentThisMonth)
                }
                .frame(maxWidth: .infinity, maxHeight: 350)
                .padding()
            } else {
                VStack {
                    Text("Please set a monthly limit in the settings in order to use this.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
}

struct CurrentMonthOverviewTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
