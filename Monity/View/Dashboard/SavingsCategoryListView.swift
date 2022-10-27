//
//  SavingsCategoryListView.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

struct SavingsCategoryListView: View {
    var category: SavingsCategory
    @ObservedObject var content: SavingsViewModel
    
    init(category: SavingsCategory) {
        self.category = category
        self.content = SavingsViewModel.forCategory(category)
    }
    
    var body: some View {
        EditableDeletableItemList(
            viewModel: content
        ) { create, edit, delete in
            ForEach(content.items) { entry in
                EditableDeletableItem(
                    item: entry,
                    confirmationTitle: "Are you sure you want to delete this entry?",
                    confirmationMessage: "This cannot be undone.",
                    onEdit: edit,
                    onDelete: delete) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.wrappedDate, format: .dateTime.year().month().day())
                            Text(item.wrappedDate, format: .dateTime.hour().minute())
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        Spacer()
                        Text(item.amount, format: .currency(code: "EUR"))
                            .foregroundColor(item.amount >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 2)
                }
            }
        } sheetContent: { showSheet, currentItem in
            SavingsEntryFormView(
                isPresented: showSheet,
                editor: SavingsEditor(entry: currentItem)
            )
        }
        .navigationTitle(category.wrappedName)
    }
}
