//
//  SettingsTransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct Settings_TransactionsView: View {
    @AppStorage("monthly_limit") private var monthlyLimit: Double?
    @StateObject private var content = SettingsTransactionsViewModel()
    @State private var showingEditAlert: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    
    var body: some View {
        EditableDeletableItemList(viewModel: content) { create, edit, delete in
            monthlyLimitSection
            Section(header: categorySectionHeader(create), footer: categorySectionFooter) {
                ForEach(content.items) { category in
                    EditableDeletableItem(
                        item: category,
                        confirmationTitle: "Are you sure you want to delete \(category.wrappedName)?",
                        confirmationMessage: "\(category.wrappedTransactionsCount) related transactions will be deleted.",
                        onEdit: edit,
                        onDelete: delete) { item in
                            VStack(alignment: .leading) {
                                Text(item.wrappedName)
                                Text("Associated transactions: \(item.wrappedTransactionsCount)")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                    }
                }
            }
        } sheetContent: { showAddItemSheet, currentItem in
            TransactionCategoryFormView(
                isPresented: showAddItemSheet,
                editor: TransactionCategoryEditor(category: currentItem)
            )
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Set monthly limit", isPresented: $showingEditAlert, actions: {
            TextField("Limit", value: $content.monthlyLimit, format: .currency(code: "EUR"))
            Button("Save") {
                UserDefaults.standard.set(content.monthlyLimit, forKey: "monthly_limit")
            }
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter your desired limit.")
        })
    }
    
    private var monthlyLimitHeader: some View {
        Text("Monthly limit")
    }
    
    private var monthlyLimitFooter: some View {
        Text("Set yourself a monthly limit and try to stay in your own budget")
    }
    
    private var monthlyLimitSection: some View {
        Section(header: monthlyLimitHeader, footer: monthlyLimitFooter) {
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
        .confirmationDialog("Delete monthly limit", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut) {
                    UserDefaults.standard.removeObject(forKey: "monthly_limit")
                }
            }
        }
    }
    
    func categorySectionHeader(_ createFunc: @escaping () -> Void) -> some View {
        HStack {
            Text("Categories")
            Spacer()
            Button(action: createFunc) {
                Image(systemName: "plus")
            }
        }
    }
    
    private var categorySectionFooter: some View {
        Text("These will help you categorize all of your expenses and income")
    }
}

struct Settings_TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_TransactionsView()
    }
}

