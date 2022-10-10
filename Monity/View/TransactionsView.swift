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
    @StateObject var content = TransactionsViewModel()
    
    var body: some View {
        NavigationView {
            List(content.transactions) { transaction in
                TransactionListTile(transaction: transaction)
            }
            .searchable(text: $searchString)
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTransactionView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView(isPresented: $showAddTransactionView)
            }
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
