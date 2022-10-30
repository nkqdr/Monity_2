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
                    Text(remainingAmount, format: .customCurrency())
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
    }
}

struct CurrentMonthOverviewTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
