//
//  MonthSummaryView.swift
//  Monity
//
//  Created by Niklas Kuder on 20.10.22.
//

import SwiftUI
import Charts

struct MonthSummaryView: View {
    var monthDate: Date
    private var content: MonthSummaryViewModel?
    
    init(monthDate: Date) {
        self.content = MonthSummaryViewModel(monthDate: monthDate)
        self.monthDate = monthDate
    }
    
    @ViewBuilder
    private var incomeExpenseRelationChart: some View {
        if let content {
            Chart(content.incomeExpenseRelationData) {
                BarMark(x: .value("Amount", $0.amount))
                    .foregroundStyle(by: .value("Type", $0.type))
                RuleMark(x: .value("Middle", 0.5))
                    .foregroundStyle(Color.secondary)
            }
            .chartForegroundStyleScale(["Expenses": Color.red.gradient, "Income": Color.green.gradient])
            .chartXScale(domain: 0 ... 1)
            .chartXAxis(.hidden)
            .frame(height: 50)
        }
    }
    
    var body: some View {
        ListBase {
            ScrollView {
                Group {
                    GroupBox(label: Text("Ratio").groupBoxLabelTextStyle()) {
                        incomeExpenseRelationChart
                    }
                    IncomeGroupBox(date: monthDate)
                    ExpensesGroupBox(date: monthDate)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
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
