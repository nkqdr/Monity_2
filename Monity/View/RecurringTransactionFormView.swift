//
//  RecurringTransactionFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import SwiftUI

struct RecurringTransactionFormView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedField: Field?
    @ObservedObject var editor: RecurringTransactionEditor
    @State private var isStillActive: Bool = true
    
    enum Field: Hashable {
        case amount
        case name
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $editor.name)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .name)
                    .font(.title.bold())
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                Section("Kategorie") {
                    TransactionCategoryPicker(selection: $editor.category)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                Section("Payment details") {
                    CurrencyInputField(value: $editor.amount)
                        .focused($focusedField, equals: .amount)
                    Picker("Cycle", selection: $editor.cycle) {
                        ForEach(TransactionCycle.allCases, id: \.self) { cycle in
                            Text(cycle.name).tag(cycle)
                        }
                    }
//                    Toggle("Is deducted", isOn: $editor.isDeducted)
                }
                Section("Timeframe") {
                    DatePicker("Start date", selection: $editor.startDate, displayedComponents: .date)
                    Toggle("Active", isOn: $editor.isStillActive)
                    if !editor.isStillActive {
                        DatePicker("End date", selection: $editor.endDate, displayedComponents: .date)
                    }
                }
                if editor.totalSpent > 0 {
                    HStack {
                        if (editor.isStillActive) {
                            Text("Total spendings until now:")
                        } else {
                            Text("Total spendings:")
                        }
                        Spacer()
                        Text(editor.totalSpent, format: .customCurrency())
                            .foregroundColor(.red)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
                }
            }
            .onAppear {
                focusedField = .name
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editor.save()
                        dismiss()
                    }
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
