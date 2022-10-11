//
//  TransactionListTile.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import SwiftUI

struct TransactionListTile: View {
    @ObservedObject var transaction: Transaction
    @State private var showConfirmationDialog: Bool = false
    var onDelete: ((Transaction) -> Void)?
    var onEdit: ((Transaction) -> Void)?
    
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
        .deleteSwipeAction {
            showConfirmationDialog.toggle()
        }
        .editSwipeAction {
            if let editFunc = onEdit {
                editFunc(transaction)
            }
        }
        .confirmationDialog("Delete transaction", isPresented: $showConfirmationDialog) {
            Button("Delete", role: .destructive) {
                if let deleteFunc = onDelete {
                    withAnimation(.easeInOut) {
                        deleteFunc(transaction)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this transaction?")
        }
    }
}

struct TransactionListTile_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListTile(transaction: Transaction())
    }
}
