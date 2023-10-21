//
//  SavingsEntryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

struct SavingsCategoryPicker: View {
    @ObservedObject var content = SavingsCategoryPickerViewModel()
    @Binding var selection: SavingsCategory?
    
    var body: some View {
        Picker("Category", selection: $selection) {
            Text("None").tag(Optional<SavingsCategory>.none)
            ForEach(content.allCategories) { category in
                Text(category.wrappedName).tag(category as Optional<SavingsCategory>)
            }
        }
    }
}

struct SavingsEntryFormView: View {
    @Binding var isPresented: Bool
    @FocusState var amountInputIsFocussed: Bool
    @ObservedObject var editor: SavingsEditor
    
    var textColor: Color {
        guard let amount = editor.amount, amount != 0 else {
            return .primary
        }
        if amount > 0 {
            return .green
        } else {
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Amount", value: $editor.amount, format: .customCurrency())
                    .keyboardType(.numbersAndPunctuation)
                    .focused($amountInputIsFocussed)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(textColor)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                Section {
                    if editor.entry == nil {
                        SavingsCategoryPicker(selection: $editor.category)
                    }
                    if let _ = editor.entry {
                        DatePicker("Timestamp", selection: $editor.timestamp)
                    }
                }
                
            }
            .onAppear {
                amountInputIsFocussed = true
            }
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
                    .disabled(!editor.isValid)
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
