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
            .onChange(of: editor.isExpense) {
                if editor.isExpense {
                    accentColor = .red
                } else {
                    accentColor = .green
                }
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
