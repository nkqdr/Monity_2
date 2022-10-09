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
    private let numberFormatter: NumberFormatter = NumberFormatter()
        
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    Picker("Choose a category", selection: $viewModel.selectedCategory) {
                        Text("None").tag(Optional<String>.none)
                        ForEach(viewModel.categories) { category in
                            Text(category.wrappedName).tag(category.name)
                        }
                    }
                    Picker("Pick a transaction type", selection: $viewModel.isExpense) {
                        Text("Income").tag(false)
                        Text("Expense").tag(true)
                    }
                    .pickerStyle(.segmented)
                    TextField("0.00€", value: $viewModel.givenAmount, formatter: numberFormatter)
                        .keyboardType(.numberPad)
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
