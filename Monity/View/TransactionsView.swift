//
//  TransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionsView: View {
    @StateObject private var listContent: TransactionDateGroupedList
    @State var showAddTransactionView = false
    @State private var showFilterSettings = false
    
    private var isCurrentMonthSelected: Bool {
        let now = Date()
        let currentMonthComps = Calendar.current.dateComponents([.year, .month], from: now)
        return listContent.selectedDateComps.year == currentMonthComps.year && listContent.selectedDateComps.month == currentMonthComps.month
    }
    
    init() {
        let now = Date()
        let calendar = Calendar.current
        let currentMonthComps = calendar.dateComponents([.year, .month], from: now)
        
        self._listContent = StateObject(wrappedValue: 
            TransactionDateGroupedList(monthComponents: currentMonthComps, groupingGranularity: .day)
        )
    }
    
    var body: some View {
        NavigationStack {
            TransactionsList(
                showAddTransactionView: $showAddTransactionView,
                transactionsByDate: listContent.groupedTransactions
            )
            .searchable(text: $listContent.searchText)
            .navigationTitle(Calendar.current.date(from: listContent.selectedDateComps)?.formatted(.dateTime.year().month()) ?? "Transactions")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFilterSettings.toggle()
                    } label: {
                        Image(systemName: isCurrentMonthSelected ? "tray.full" : "tray.full.fill")
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
            .monthYearSelectorSheet($showFilterSettings, selection: $listContent.selectedDateComps)
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
