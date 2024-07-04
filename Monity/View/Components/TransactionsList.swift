//
//  TransactionsList.swift
//  Monity
//
//  Created by Niklas Kuder on 23.10.22.
//

import SwiftUI

fileprivate struct TransactionListTile: View {
    @ObservedObject var transaction: Transaction
    @State var showEditView: Bool = false
    @State private var showConfirmationDialog: Bool = false
    
    var body: some View {
        HStack {
            if let icon = transaction.category?.iconName {
                Image(systemName: icon)
                    .padding(.trailing, 10)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(transaction.category?.wrappedName ?? "No category"))
                    .font(.headline)
                Text(transaction.wrappedText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .customCurrency())
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .deleteSwipeAction {
            showConfirmationDialog.toggle()
        }
        .editSwipeAction {
            showEditView.toggle()
        }
        .contextMenu {
            Button {
                showEditView.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                showConfirmationDialog.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEditView) {
            AddTransactionView(
                isPresented: $showEditView,
                editor: TransactionEditor(transaction: transaction)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .confirmationDialog(
            "Delete transaction",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    TransactionStorage.main.delete(transaction)
                }
            }
        } message: {
            Text("Are you sure you want to delete this transaction?")
        }
    }
}

struct TransactionsList: View {
    @Binding var showAddTransactionView: Bool
    var transactionsByDate: [TransactionsByDate]
    var dateFormat: Date.FormatStyle = .dateTime.year().month().day()
    
    func getTransactionSumFor(_ list: [Transaction], isExpense: Bool) -> Double {
        return list.filter({ $0.isExpense == isExpense }).map({ $0.amount }).reduce(0, +)
    }
    
    @ViewBuilder
    func sectionHeaderFor(_ transactionByDate: TransactionsByDate) -> some View {
        HStack {
            Text(transactionByDate.date, format: dateFormat)
            Spacer()
            HStack(spacing: 1) {
                Text(getTransactionSumFor(transactionByDate.transactions, isExpense: true), format: .customCurrency())
                    .foregroundColor(.red)
                Text(" | ")
                Text(getTransactionSumFor(transactionByDate.transactions, isExpense: false), format: .customCurrency())
                    .foregroundColor(.green)
            }
        }
    }
    
    var body: some View {
        List(transactionsByDate) { date in
            Section(header: sectionHeaderFor(date)) {
                ForEach(date.transactions) { transaction in
                    TransactionListTile(transaction: transaction)
                }
            }
        }
        .sheet(isPresented: $showAddTransactionView) {
            AddTransactionView(isPresented: $showAddTransactionView, editor: TransactionEditor(transaction: nil))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}
