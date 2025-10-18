//
//  TransactionForm.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

fileprivate struct TransactionForm: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedField: Field?
    @StateObject var editor: TransactionEditor
    @Binding var accentColor: Color
    
    enum Field: Hashable {
        case amount
        case text
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
                .listRowBackground(Color.clear)
                
                Section {
                    TransactionCategoryPicker(selection: $editor.selectedCategory)
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
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if editor.transaction == nil {
                    focusedField = .amount
                }
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
                            editor.save()
                        }
                        dismiss()
                    }
                    .disabled(!editor.isValid)
                    .buttonStyle(.glassProminent)
                }
            }
            .closeKeyboardToolbar()
            .onChange(of: editor.isExpense) {
                accentColor = editor.isExpense ? .red : .green
            }
        }
    }
}

fileprivate struct CreateTransactionFormModifier: ViewModifier {
    @State var accentColor: Color = .red
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            TransactionForm(
                editor: TransactionEditor(transaction: nil),
                accentColor: $accentColor
            )
                .presentationDragIndicator(.hidden)
                .presentationBackground(accentColor.opacity(0.2))
        }
    }
}

fileprivate struct EditTransactionFormModifier: ViewModifier {
    @State var accentColor: Color = .red
    @Binding var transaction: Transaction?
    
    func body(content: Content) -> some View {
        content.sheet(item: $transaction) { t in
            TransactionForm(
                editor: TransactionEditor(transaction: t),
                accentColor: $accentColor
            )
                .presentationDragIndicator(.hidden)
                .presentationBackground(accentColor.opacity(0.2))
        }
    }
}

extension View {
    func transactionFormSheet(isPresented: Binding<Bool>) -> some View {
        self.modifier(CreateTransactionFormModifier(isPresented: isPresented))
    }
    
    func transactionFormSheet(transaction: Binding<Transaction?>) -> some View {
        self.modifier(EditTransactionFormModifier(transaction: transaction))
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionForm(editor: TransactionEditor(), accentColor: .constant(.red))
    }
}
