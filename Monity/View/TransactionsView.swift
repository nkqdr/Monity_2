//
//  TransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionsView: View {
    @StateObject private var viewModel = MonthlyTransactionsViewModel()
    @State var showAddTransactionView = false
    @State private var searchValue: String = ""
    @State private var showFilterSettings = false
    @State private var temporaryDateSelection = Calendar.current.dateComponents([.month, .year], from: Date())
    
    var body: some View {
        NavigationStack {
            TransactionsList(
                showAddTransactionView: $showAddTransactionView,
                transactionsByDate: viewModel.currentTransactionsByDate
            )
            .searchable(text: $searchValue)
            .onChange(of: searchValue) { newValue in
                viewModel.filterTransactionsByValue(newValue)
            }
            .navigationTitle("Transactions")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        temporaryDateSelection = viewModel.filteredSelectedDate
                        showFilterSettings.toggle()
                    } label: {
                        Image(systemName: viewModel.isCurrentMonthSelected ? "tray.full" : "tray.full.fill")
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
            .monthYearSelectorSheet($showFilterSettings, selection: $viewModel.filteredSelectedDate)
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
