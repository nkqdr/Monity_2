//
//  TransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionsView: View {
    @State var showAddTransactionView = false
    @State private var showFilterSettings = false
    @StateObject var content = TransactionsViewModel.shared
    @State private var temporaryDateSelection = Calendar.current.dateComponents([.month, .year], from: Date())
    
    var body: some View {
        NavigationView {
            TransactionsList(
                showAddTransactionView: $showAddTransactionView,
                transactionsByDate: content.currentTransactionsByDate
            )
            .navigationTitle("Transactions")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        temporaryDateSelection = content.filteredSelectedDate
                        showFilterSettings.toggle()
                    } label: {
                        Image(systemName: content.isCurrentMonthSelected ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
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
                    Text("Selected month")
                        .padding()
                    MonthYearPicker(dateSelection: $temporaryDateSelection)
                        .frame(height: 150)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .padding()
                    Button("Today") {
                        withAnimation(.spring()) {
                            temporaryDateSelection = Calendar.current.dateComponents([.month, .year], from: Date())
                        }
                    }
                    Spacer()
                    Button("Apply") {
                        content.filteredSelectedDate = temporaryDateSelection
                        print(content.filteredSelectedDate)
                        showFilterSettings = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .presentationDetents([.medium])
            }
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
