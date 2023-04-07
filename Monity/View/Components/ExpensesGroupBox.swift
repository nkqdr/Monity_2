//
//  ExpensesGroupBox.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI

struct ExpensesGroupBox: View {
    @ObservedObject private var expenseCalculator: MonthExpenseCalculator
    
    init(date: Date = Date()) {
        if (date.isSameMonthAs(Date())) {
            self.expenseCalculator = MonthExpenseCalculator.current
        } else {
            self.expenseCalculator = MonthExpenseCalculator(date: date)
        }
    }
    
    var body: some View {
        GroupBox(label: Text("Expenses").groupBoxLabelTextStyle()) {
            CurrencyPieChart(
                values: expenseCalculator.expenseDataPoints,
                backgroundColor: .clear,
                centerLabel: expenseCalculator.totalExpenses,
                emptyString: "No registered expenses for this month."
            )
        }
    }
}

struct ExpensesGroupBox_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesGroupBox()
    }
}
