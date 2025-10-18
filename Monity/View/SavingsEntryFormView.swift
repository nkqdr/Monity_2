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
    @Environment(\.dismiss) var dismiss
    @FocusState var amountInputIsFocused: Bool
    @ObservedObject var editor: SavingsEditor
    
    var textColor: Color {
        if editor.amount > 0 {
            return .green
        } else if editor.amount == 0 {
            return .primary
        } else {
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                CurrencyInputField(value: $editor.amount, maxDigits: 13)
                    .focused($amountInputIsFocused)
                    .font(.title.bold())
                    .foregroundStyle(textColor)
                    .listRowBackground(Color.clear)
                    .autocorrectionDisabled()

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
                amountInputIsFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", systemImage: "checkmark") {
                        withAnimation {
                            DispatchQueue.main.async {
                                editor.save()
                            }
                        }
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!editor.isValid)
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SavingsEntryFormView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsEntryFormView(editor: SavingsEditor(entry: nil))
    }
}
