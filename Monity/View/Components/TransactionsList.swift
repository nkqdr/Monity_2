//
//  TransactionsList.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI

struct TransactionsList: View {
    @State private var currentTransaction: Transaction?
    @Binding var showAddTransactionView: Bool
    var transactionsByDate: [TransactionsByDate]
    var dateFormat: Date.FormatStyle = .dateTime.year().month().day()
    
    func deleteTransaction(_ transaction: Transaction) {
        TransactionStorage.shared.delete(transaction)
    }
    
    func showEditSheetForTransaction(_ transaction: Transaction) {
        currentTransaction = transaction
        showAddTransactionView.toggle()
    }
    
    var body: some View {
        List(transactionsByDate) { date in
            Section(header: Text(date.date, format: dateFormat)) {
                ForEach(date.transactions) { transaction in
                    EditableDeletableItem(
                        item: transaction,
                        confirmationTitle: "Delete transaction",
                        confirmationMessage: "Are you sure you want to delete this transaction?",
                        onEdit: showEditSheetForTransaction,
                        onDelete: deleteTransaction) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.category?.wrappedName ?? "No category")
                                        .font(.headline)
                                    Text(item.wrappedText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.amount, format: .customCurrency())
                                    .foregroundColor(item.isExpense ? .red : .green)
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTransactionView) {
            AddTransactionView(isPresented: $showAddTransactionView, editor: TransactionEditor(transaction: currentTransaction))
        }
        .onChange(of: showAddTransactionView) { newValue in
            if !newValue {
                currentTransaction = nil
            }
        }
    }
}
