//
//  RecurringTransactionsTile.swift
//  Monity
//
//  Created by Niklas Kuder on 03.03.23.
//

import SwiftUI

struct RecurringTransactionsTile: View {
    @ObservedObject private var content = RecurringTransactionsViewModel.shared
    
    @ViewBuilder
    private var actualTile: some View {
        VStack(alignment: .leading) {
            Text("You are currently paying \(content.currentMonthlyPayment.formatted(.customCurrency())) per month")
                .groupBoxLabelTextStyle()
            RecurringTransactionsLineChart()
        }
    }
    
    var body: some View {
        NavigationLink(destination: RecurringTransactionsDetailView()) {
            GroupBox(label: NavigationGroupBoxLabel(title: "Recurring expenses")) {
                actualTile
            }
            .groupBoxStyle(CustomGroupBox())
            .contextMenu {
                RenderAndShareButton(height: 250) {
                    VStack(alignment: .leading) {
                        Text("Recurring expenses").groupBoxLabelTextStyle(.secondary)
                        Spacer()
                        actualTile
                    }
                    .padding()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct RecurringTransactionsTile_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsTile()
    }
}
