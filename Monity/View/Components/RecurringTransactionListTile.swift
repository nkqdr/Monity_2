//
//  RecurringTransactionListTile.swift
//  Monity
//
//  Created by Niklas Kuder on 03.03.23.
//

import SwiftUI

struct RecurringTransactionListTile: View {
    var transaction: RecurringTransaction
    
    @ViewBuilder
    private var dateRange: some View {
        if let startDate = transaction.startDate {
            Text(startDate, format: .dateTime.year().month().day()) + Text(" - ") + (transaction.endDate != nil ? Text(transaction.endDate!, format: .dateTime.year().month().day()) : Text("Today"))
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.wrappedName)
                dateRange
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(transaction.amount, format: .customCurrency())
                    .foregroundColor(.red)
                Text(TransactionCycle.fromValue(transaction.cycle)?.name ?? "")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}
