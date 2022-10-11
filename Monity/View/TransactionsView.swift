//
//  TransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionsView: View {
    @State var searchString = ""
    @State var showAddTransactionView = false
    @State private var showFilterSettings = false
    @StateObject var content = TransactionsViewModel()
    @State private var temporaryDateSelection = Calendar.current.dateComponents([.month, .year], from: Date())
    
    func showEditSheetForTransaction(_ transaction: Transaction) {
        content.currentTransaction = transaction
        showAddTransactionView.toggle()
    }
    
    var body: some View {
        NavigationView {
            List(content.transactions) { transaction in
                TransactionListTile(transaction: transaction, onDelete: content.deleteTransaction, onEdit: showEditSheetForTransaction)
            }
            .searchable(text: $searchString)
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        temporaryDateSelection = content.filteredSelectedDate
                        showFilterSettings.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTransactionView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showFilterSettings) {
                VStack {
                    Form {
                        Section("Selected month") {
                            MonthYearPicker(dateSelection: $temporaryDateSelection)
                                .frame(height: 100)
                        }
//                        Section("Advanced filters") {
//
//                        }
                    }
                    Button("Apply") {
                        content.filteredSelectedDate = temporaryDateSelection
                        print(content.filteredSelectedDate)
                        showFilterSettings = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView(isPresented: $showAddTransactionView, editor: TransactionEditor(transaction: content.currentTransaction))
            }
            .onChange(of: showAddTransactionView) { newValue in
                if !newValue {
                    content.currentTransaction = nil
                }
            }
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
