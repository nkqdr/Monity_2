//
//  MonthSummaryView.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import SwiftUI

struct MonthSummaryView: View {
    var monthDate: Date
    private var content: MonthSummaryViewModel?
    
    init(monthDate: Date) {
        self.content = MonthSummaryViewModel(monthDate: monthDate)
        self.monthDate = monthDate
    }
    
    @ViewBuilder
    private var incomePieChart: some View {
        VStack(alignment: .leading) {
            Text("Income").groupBoxLabelTextStyle()
            if let content {
                CurrencyPieChart(values: content.incomeDataPoints, backgroundColor: .clear, centerLabel: content.earnedThisMonth, emptyString: "No registered income for this month.")
            }
        }
    }
    
    @ViewBuilder
    private var expensePieChart: some View {
        VStack(alignment: .leading) {
            Text("Expenses").groupBoxLabelTextStyle()
            if let content {
                CurrencyPieChart(values: content.expenseDataPoints, backgroundColor: .clear, centerLabel: content.spentThisMonth, emptyString: "No registered expenses for this month.")
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                incomePieChart
            }
            Section {
                expensePieChart
            }
        }
        .navigationTitle(Text(monthDate, format: .dateTime.year().month()))
    }
}

struct MonthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MonthSummaryView(monthDate: Date())
    }
}
