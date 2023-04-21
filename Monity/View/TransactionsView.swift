//
//  TransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionsView: View {
    @State var showAddTransactionView = false
    @State private var searchValue: String = ""
    @State private var showFilterSettings = false
    @ObservedObject var content = TransactionsViewModel.shared
    @State private var temporaryDateSelection = Calendar.current.dateComponents([.month, .year], from: Date())
    
    var body: some View {
        NavigationView {
            TransactionsList(
                showAddTransactionView: $showAddTransactionView,
                transactionsByDate: content.currentTransactionsByDate
            )
            .searchable(text: $searchValue)
            .onChange(of: searchValue) { newValue in
                if newValue.isEmpty {
                    content.resetTransactionsSearch()
                } else {
                    content.filterTransactionsByValue(newValue)
                }
            }
            .navigationTitle("Transactions")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        temporaryDateSelection = content.filteredSelectedDate
                        showFilterSettings.toggle()
                    } label: {
                        Image(systemName: content.isCurrentMonthSelected ? "tray.full" : "tray.full.fill")
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
            .monthYearSelectorSheet($showFilterSettings, selection: $content.filteredSelectedDate)
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
