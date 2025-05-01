//
//  RecurringTransactionsDetailView.swift
//  Monity
//
//  Created by Niklas Kuder on 03.03.23.
//

import SwiftUI

fileprivate struct RecurringTransactionListTile: View {
    @ObservedObject var transaction: RecurringTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.wrappedName)
                if let startDate = transaction.startDate {
                    Group {
                        Text(startDate, format: .dateTime.year().month().day()) + Text(" - ") + (transaction.endDate != nil ? Text(transaction.endDate!, format: .dateTime.year().month().day()) : Text("Today"))
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
                   
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

struct RecurringTransactionsDetailView: View {
    @ObservedObject private var content = RecurringTransactionsViewModel.shared
    @State private var showArchivedTransactions: Bool = false
    @State private var currentDataPoint: ValueTimeDataPoint? = nil
    
    @ViewBuilder
    func savingsCategoriesHeader(_ createFunc: @escaping () -> Void) -> some View {
        HStack {
            Text("Active expenses")
            Spacer()
            Button(action: createFunc) {
                Image(systemName: "plus")
            }
        }
    }
    
    var archivedTransactionsList: some View {
        EditableDeletableItemList(viewModel: content, presentationDetents: [.large]) { create, edit, delete in
            ForEach(content.archivedTransactions) { category in
                EditableDeletableItem(
                    item: category,
                    confirmationTitle: "Are you sure you want to delete \(category.wrappedName)?",
                    onEdit: edit,
                    onDelete: delete) { item in
                        RecurringTransactionListTile(transaction: item)
                    }
            }
        } sheetContent: { showAddSheet, currentItem in
            RecurringTransactionFormView(editor: RecurringTransactionEditor(transaction: currentItem))
        }
    }
    
    var body: some View {
        EditableDeletableItemList(viewModel: content, presentationDetents: [.large]) { create, edit, delete in
            VStack(alignment: .leading) {
                Text(currentDataPoint?.value ?? content.currentMonthlyPayment, format: .customCurrency())
                    .font(.title2.bold())
                Text(currentDataPoint?.date ?? Date(), format: .dateTime.year().month().day())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                RecurringTransactionsLineChart(selectedDataPoint: $currentDataPoint)
                    .frame(minHeight: 250)
                    .padding(.vertical)
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            .listRowInsets(EdgeInsets())
            Section(header: savingsCategoriesHeader(create)) {
                ForEach(content.activeTransactions) { entry in
                    EditableDeletableItem(
                        item: entry,
                        confirmationTitle: "Are you sure you want to delete \(entry.wrappedName)?",
                        onEdit: edit,
                        onDelete: delete) { item in
                            RecurringTransactionListTile(transaction: item)
                        }
                }
            }
        } sheetContent: { showAddSheet, currentItem in
            RecurringTransactionFormView(editor: RecurringTransactionEditor(transaction: currentItem))
        }
        .sheet(isPresented: $showArchivedTransactions) {
            NavigationView {
                archivedTransactionsList
                    .navigationTitle("Archive")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                showArchivedTransactions.toggle()
                            }
                        }
                    }
            }
        }
        .navigationTitle("Recurring expenses")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showArchivedTransactions.toggle()
                } label: {
                    Image(systemName: "tray.full")
                }
            }
        }
    }
}

struct RecurringTransactionsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsDetailView()
    }
}
