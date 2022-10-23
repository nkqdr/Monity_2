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
                    TransactionListTile(
                        transaction: transaction,
                        onDelete: deleteTransaction,
                        onEdit: showEditSheetForTransaction
                    )
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
