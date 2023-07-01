//
//  AverageExpenseAndIncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct AverageExpenseAndIncomeTile: View {
    @StateObject private var content = AverageMonthlyChartViewModel.shared
    
    @ViewBuilder
    private var expenseChart: some View {
        AverageOneYearBarChart(data: content.monthlyExpenseDataPoints, average: content.averageExpenses, tint: .red)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var incomeChart: some View {
        AverageOneYearBarChart(data: content.monthlyIncomeDataPoints, average: content.averageIncome, tint: .green)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var actualTile: some View {
        let percentOfIncomeSpent: Int? = content.totalIncomeThisYear > 0 ? Int(content.totalExpensesThisYear / content.totalIncomeThisYear * 100) : nil
        VStack(alignment: .leading) {
            if let percentOfIncomeSpent {
                Text("You saved \(100 - percentOfIncomeSpent)% of your income.")
                    .groupBoxLabelTextStyle()
            } else {
                Text("Register your transactions to build the statistics!")
                    .groupBoxLabelTextStyle()
            }
            expenseChart
                .padding(.top, percentOfIncomeSpent != nil ? 0 : 10)
            incomeChart
        }
    }
    
    var body: some View {
        NavigationLink(destination: AverageExpenseDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Last Year")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
        }
        .buttonStyle(.plain)
    }
}

struct AverageExpensesTile_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
