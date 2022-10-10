//
//  AddTransactionView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct AddTransactionView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var viewModel = AddTransactionViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    Picker("Choose a category", selection: $viewModel.selectedCategory) {
                        Text("None").tag(Optional<TransactionCategory>.none)
                        ForEach(viewModel.categories) { category in
                            Text(category.wrappedName).tag(category as TransactionCategory?)
                        }
                    }
                    Picker("Pick a transaction type", selection: $viewModel.isExpense) {
                        Text("Income").tag(false)
                        Text("Expense").tag(true)
                    }
                    .pickerStyle(.segmented)
                    TextField("Amount", value: $viewModel.givenAmount, format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                }
                Section("Optional") {
                    TextField("Description", text: $viewModel.description)
                    //TextField("Tag", text: $viewModel.tag)
                }
            }
            .navigationTitle("Add transaction")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.save()
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(isPresented: .constant(true))
    }
}
