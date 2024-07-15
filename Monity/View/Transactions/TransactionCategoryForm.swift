//
//  TransactionCategoryForm.swift
//  Monity
//
//  Created by Niklas Kuder on 14.07.24.
//

import SwiftUI

struct TransactionCategoryForm: View {
    @FocusState private var focusNameField
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
                    .focused($focusNameField)
                Section {
                    IconPicker(selection: $editor.selectedIcon, title: "Icon")
                } header: {
                    Text("Details")
                }
            }
            .onAppear {
                self.focusNameField = true
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
            }
        }
    }
}
