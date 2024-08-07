//
//  AddTransactionView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedField: Field?
    @StateObject var editor: TransactionEditor
    
    enum Field: Hashable {
        case amount
        case text
    }
    
    var accentColor: Color {
        editor.isExpense ? .red : .green
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 10) {
                    CurrencyInputField(value: $editor.givenAmount)
                        .focused($focusedField, equals: .amount)
                        .font(.largeTitle.bold())
                        .foregroundStyle(accentColor)
                        .autocorrectionDisabled()
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
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .tint(accentColor)
                } header: {
                    Text("Category")
                }
                
                if let _ = editor.transaction {
                    Section {
                        DatePicker("Timestamp", selection: $editor.selectedDate)
                    }
                    .listRowBackground(accentColor.opacity(0.25))
                }
                Section("Optional") {
                    TextField("Description", text: $editor.description)
                        .focused($focusedField, equals: .text)
                }
                .listRowBackground(accentColor.opacity(0.25))
            }
            .scrollContentBackground(.hidden)
            .background(accentColor.opacity(0.2))
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if editor.transaction == nil {
                    focusedField = .amount                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        withAnimation {
                            editor.save()
                        }
                        dismiss()
                    }
                    .disabled(!editor.isValid)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                }
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(editor: TransactionEditor())
    }
}
