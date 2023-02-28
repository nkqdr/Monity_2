//
//  More_RecurringTransactionsView.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import SwiftUI

struct More_RecurringTransactionsView: View {
    @ObservedObject private var content = RecurringTransactionsViewModel.shared
    
    @ViewBuilder
    func savingsCategoriesHeader(_ createFunc: @escaping () -> Void) -> some View {
        HStack {
            Text("Your recurring transactions")
            Spacer()
            Button(action: createFunc) {
                Image(systemName: "plus")
            }
        }
    }
    
    var body: some View {
        EditableDeletableItemList(viewModel: content) { create, edit, delete in
            Section(header: savingsCategoriesHeader(create)) {
                ForEach(content.items) { category in
                    EditableDeletableItem(
                        item: category,
                        confirmationTitle: "Are you sure you want to delete \(category.wrappedName)?",
                        onEdit: edit,
                        onDelete: delete) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.wrappedName)
                                }
                                Spacer()
                            }
                        }
                }
            }
        } sheetContent: { showAddSheet, currentItem in
            RecurringTransactionFormView(isPresented: showAddSheet, editor: RecurringTransactionEditor(transaction: currentItem))
        }
        .navigationTitle("Recurring Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct More_RecurringTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        More_RecurringTransactionsView()
    }
}
