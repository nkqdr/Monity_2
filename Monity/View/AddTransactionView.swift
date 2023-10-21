//
//  AddTransactionView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct AddTransactionView: View {
    @Binding var isPresented: Bool
    @FocusState var amountInputIsFocussed: Bool
    @StateObject var editor: TransactionEditor
    
    var body: some View {
        NavigationView {
            Form {
                VStack(spacing: 10) {
                    TextField("Amount", value: $editor.givenAmount, format: .customCurrency())
                        .keyboardType(.numbersAndPunctuation)
                        .focused($amountInputIsFocussed)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(editor.isExpense ? .red : .green)
                    Picker("Pick a transaction type", selection: $editor.isExpense) {
                        Text("Income").tag(false)
                        Text("Expense").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                Section {
                    TransactionCategoryPicker(selection: $editor.selectedCategory)
                    
                    if let _ = editor.transaction {
                        DatePicker("Timestamp", selection: $editor.selectedDate)
                    }
                }
                Section("Optional") {
                    TextField("Description", text: $editor.description)
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if editor.transaction == nil {
                    amountInputIsFocussed = true
                }
            }
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
                    .disabled(!editor.isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
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
