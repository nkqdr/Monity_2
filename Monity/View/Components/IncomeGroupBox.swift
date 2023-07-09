//
//  IncomeGroupBox.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI

struct IncomeGroupBox: View {
    @ObservedObject var incomeCalculator: MonthIncomeCalculator
    private var date: Date
    
    init(date: Date = Date()) {
        self.date = date
        if (date.isSameMonthAs(Date())) {
            self.incomeCalculator = MonthIncomeCalculator.current
        } else {
            self.incomeCalculator = MonthIncomeCalculator(date: date)
        }
    }
    
    var body: some View {
        GroupBox(label: Text("income.plural").groupBoxLabelTextStyle()) {
            CurrencyPieChart(
                values: incomeCalculator.incomeDataPoints,
                backgroundColor: .clear,
                centerLabel: incomeCalculator.totalIncome,
                emptyString: "No registered income for this month."
            )
        }
    }
}

struct IncomeGroupBox_Previews: PreviewProvider {
    static var previews: some View {
        IncomeGroupBox()
    }
}
