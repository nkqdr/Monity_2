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
                    .font(.largeTitle.bold())
                    .focused($focusedField, equals: .name)
                Section {
                    IconPicker(selection: $editor.selectedIcon, title: "Icon")
                } header: {
                    Text("Details")
                }
            }
            .onAppear {
                self.focusedField = .name
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", systemImage: "checkmark") {
                        let category = editor.save()
                        onSave(category)
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!editor.isValid)
                }
            }
            .closeKeyboardToolbar()
        }
    }
}

struct TransactionCategoryForm_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryForm(editor: TransactionCategoryEditor())
    }
}
