//
//  SettingsTransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct Settings_TransactionsView: View {
    @StateObject private var content = SettingsTransactionsViewModel()
    @State private var showAddCategorySheet: Bool = false
    
    var body: some View {
        List {
            monthlyLimitSection
            transactionCategorySection
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCategorySheet) {
            TransactionCategoryFormView(isPresented: $showAddCategorySheet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var monthlyLimitSection: some View {
        Section(header: Text("Monthly limit"), footer: Text("Set yourself a monthly limit and try to stay in your own budget")) {
            HStack {
                Text("Your monthly limit:")
                Spacer()
                Text(content.monthlyLimit, format: .currency(code: "EUR"))
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
            HStack {
                Button("Change limit") {
                    
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Delete limit", role: .destructive) {
                    
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private var transactionCategorySection: some View {
        Section(header: HStack {
            Text("Categories")
            Spacer()
            Button {
                showAddCategorySheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }, footer: Text("These will help you categorize all of your expenses and income")) {
            ForEach(content.categories) { category in
                Text(category.wrappedName)
            }
        }
    }
}

struct Settings_TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_TransactionsView()
    }
}

