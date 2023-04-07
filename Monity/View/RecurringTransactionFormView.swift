//
//  RecurringTransactionFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import SwiftUI

struct RecurringTransactionFormView: View {
    @Binding var isPresented: Bool
    @ObservedObject var editor: RecurringTransactionEditor
    @State private var isStillActive: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $editor.name)
                TransactionCategoryPicker(selection: $editor.category)
                Section("Payment details") {
                    TextField("Amount", value: $editor.amount, format: .customCurrency())
                        .keyboardType(.decimalPad)
                    Picker("Cycle", selection: $editor.cycle) {
                        ForEach(TransactionCycle.allCases, id: \.self) { cycle in
                            Text(cycle.name).tag(cycle)
                        }
                    }
                    Toggle("Is deducted", isOn: $editor.isDeducted)
                }
                Section("Timeframe") {
                    DatePicker("Start date", selection: $editor.startDate, displayedComponents: .date)
                    Toggle("Active", isOn: $editor.isStillActive)
                    if !editor.isStillActive {
                        DatePicker("End date", selection: $editor.endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
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
                }
            }
        }
    }
}
