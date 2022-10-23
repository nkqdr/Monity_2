//
//  AverageExpenseAndIncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct AverageExpenseAndIncomeTile: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    private var expenseChart: some View {
        AverageOneYearBarChart(data: content.monthlyExpenseDataPoints, average: content.averageExpenses, tint: .red)
            .padding(.horizontal, 4)
    }
    
    private var incomeChart: some View {
        AverageOneYearBarChart(data: content.monthlyIncomeDataPoints, average: content.averageIncome, tint: .green)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var actualTile: some View {
        let percentOfIncomeSpent: Int = Int(content.totalExpensesThisYear / content.totalIncomeThisYear * 100)
        VStack(alignment: .leading) {
            HStack {
                Text("Transaction Overview").groupBoxLabelTextStyle(.secondary)
                Spacer()
                Text("Last Year").groupBoxLabelTextStyle(.secondary)
            }
            Spacer()
            Text("You spent \(percentOfIncomeSpent)% of your income.")
                .groupBoxLabelTextStyle()
            expenseChart
            incomeChart
        }
    }
    var body: some View {
        Section {
            NavigationLink(destination: AverageExpenseDetailView()) {
                actualTile
            }
        }
    }
}

struct AverageExpensesTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
