//
//  TransactionCategoryForm.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI

fileprivate enum Field {
    case name, budget
}

struct TransactionCategoryForm: View {
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss
    @StateObject var editor: TransactionCategoryEditor
    var onSave: (TransactionCategory) -> Void = { _ in }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $editor.name)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .font(.largeTitle.bold())
                    .focused($focusedField, equals: .name)
                Section {
                    IconPicker(selection: $editor.selectedIcon, title: "Icon")
                    BudgetInput("Budget", value: $editor.budgetAmount)
                        .focused($focusedField, equals: .budget)
                } header: {
                    Text("Details")
                }
            }
            .onAppear {
                self.focusedField = .name
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let category = editor.save()
                        onSave(category)
                        dismiss()
                    }
                    .disabled(!editor.isValid)
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}
