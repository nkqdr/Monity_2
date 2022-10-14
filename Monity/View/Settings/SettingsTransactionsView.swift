//
//  SettingsTransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct Settings_TransactionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("monthly_limit") private var monthlyLimit: Double?
    @StateObject private var content = SettingsTransactionsViewModel()
    @State private var showAddCategorySheet: Bool = false
    @State private var showingEditAlert: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    
    var body: some View {
        List {
            monthlyLimitSection
            transactionCategorySection
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCategorySheet) {
            TransactionCategoryFormView(isPresented: $showAddCategorySheet, editor: TransactionCategoryEditor(category: content.currentCategory))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: showAddCategorySheet) { newValue in
            if !newValue {
                content.currentCategory = nil
            }
        }
    }
    
    private var monthlyLimitSection: some View {
        Section(header: Text("Monthly limit"), footer: Text("Set yourself a monthly limit and try to stay in your own budget")) {
            HStack {
                Text("Your monthly limit:")
                Spacer()
                if let limit = monthlyLimit {
                    Text(limit, format: .currency(code: "EUR"))
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else {
                    Text("None")
                        .foregroundColor(.gray)
                }
            }
            HStack {
                Button("Change limit") {
                    showingEditAlert.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Delete limit", role: .destructive) {
                    showingDeleteConfirmation.toggle()
                }
                .buttonStyle(.borderless)
            }
        }
        .alert("Set monthly limit", isPresented: $showingEditAlert, actions: {
            TextField("Limit", value: $content.monthlyLimit, format: .currency(code: "EUR"))
            Button("Save") {
                UserDefaults.standard.set(content.monthlyLimit, forKey: "monthly_limit")
            }
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter your desired limit.")
        })
        .confirmationDialog("Delete monthly limit", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    UserDefaults.standard.removeObject(forKey: "monthly_limit")
                }
            }
        }
    }
    
    func showEditSheetForCategory(_ category: TransactionCategory) {
        content.currentCategory = category
        showAddCategorySheet.toggle()
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
                TransactionCategoryListTile(category: category, onEdit: showEditSheetForCategory, onDelete: content.deleteCategory)
            }
        }
    }
}

struct Settings_TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_TransactionsView()
    }
}

