//
//  TransactionListTile.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import SwiftUI

struct TransactionListTile: View {
    @ObservedObject var transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.category?.wrappedName ?? "No category")
                    .font(.headline)
                Text(transaction.wrappedText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: "EUR"))
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
    }
}

struct TransactionListTile_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListTile(transaction: Transaction())
    }
}
