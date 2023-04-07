//
//  AddTransactionView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct AddTransactionView: View {
    @Binding var isPresented: Bool
    @ObservedObject var editor: TransactionEditor
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TransactionCategoryPicker(selection: $editor.selectedCategory)
                    Picker("Pick a transaction type", selection: $editor.isExpense) {
                        Text("Income").tag(false)
                        Text("Expense").tag(true)
                    }
                    .pickerStyle(.segmented)
                    TextField("Amount", value: $editor.givenAmount, format: .customCurrency())
                        .keyboardType(.decimalPad)
                    if let _ = editor.transaction {
                        DatePicker("Transaction date", selection: $editor.selectedDate, displayedComponents: .date)
                    }
                }
                Section("Optional") {
                    TextField("Description", text: $editor.description)
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editor.save()
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(isPresented: .constant(true), editor: TransactionEditor())
    }
}
