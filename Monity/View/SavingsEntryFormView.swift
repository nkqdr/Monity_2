//
//  SavingsEntryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

struct SavingsEntryFormView: View {
    @Binding var isPresented: Bool
    @ObservedObject var editor: SavingsEditor
    @ObservedObject var categoryContent = SavingsCategoryViewModel.shared
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Category", selection: $editor.category) {
                    Text("None").tag(Optional<SavingsCategory>.none)
                    ForEach(categoryContent.shownCategories) { category in
                        Text(category.wrappedName).tag(category as Optional<SavingsCategory>)
                    }
                }
                TextField("Amount", value: $editor.amount, format: .customCurrency())
                    .keyboardType(.decimalPad)
                if let _ = editor.entry {
                    Section {
                        DatePicker("Timestamp", selection: $editor.timestamp)
                    }
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editor.save()
                        isPresented = false
                    }
                    .disabled(editor.disableSave)
                }
            }
        }
    }
}
