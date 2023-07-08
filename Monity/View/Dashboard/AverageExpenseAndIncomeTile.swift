//
//  AverageExpenseAndIncomeTile.swift
//  Monity
//
//  Created by Niklas Kuder on 17.10.22.
//

import SwiftUI

struct AverageExpenseAndIncomeTile: View {
    @StateObject private var content = TransactionSummaryViewModel()
    
    @ViewBuilder
    private var expenseChart: some View {
        AverageOneYearBarChart(data: content.expenseBarChartData, average: content.averageExpenses, tint: .red)
            .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private var incomeChart: some View {
        AverageOneYearBarChart(data: content.incomeBarChartData, average: content.averageIncome, tint: .green)
            .padding(.horizontal, 4)
    }
    
    private var percentage: Double? {
        return content.percentageOfIncomeSpent
    }
    
    @ViewBuilder
    private var actualTile: some View {
        VStack(alignment: .leading) {
            if let percentage {
                Text("You saved \(Int((1 - percentage) * 100))% of your income.")
                    .groupBoxLabelTextStyle()
            } else {
                Text("Register your transactions to build the statistics!")
                    .groupBoxLabelTextStyle()
            }
            expenseChart
                .padding(.top, percentage != nil ? 0 : 10)
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
