//
//  RecurringTransactionsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 03.03.23.
//

import SwiftUI

struct RecurringTransactionsTile: View {
    @ObservedObject private var content = RecurringTransactionsViewModel.shared
    
    var body: some View {
        NavigationLink(destination: RecurringTransactionsDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Recurring transactions")) {
                VStack(alignment: .leading) {
                    Text("You are currently paying \(content.currentMonthlyPayment.formatted(.customCurrency())) per month.")
                        .groupBoxLabelTextStyle()
                    RecurringTransactionsLineChart()
                }
            }
            .groupBoxStyle(CustomGroupBox())
        }
        .buttonStyle(.plain)
    }
}

struct RecurringTransactionsTile_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsTile()
    }
}
