//
//  TransactionCategoryListTile.swift
//  Monity
//
//  Created by Niklas Kuder on 10.10.22.
//

import SwiftUI

struct TransactionCategoryListTile: View {
    @State private var showConfirmationDialog: Bool = false
    var category: TransactionCategory
    var onEdit: ((TransactionCategory) -> Void)?
    var onDelete: ((TransactionCategory) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category.wrappedName)
            Text("Associated transactions: \(category.wrappedTransactionsCount)")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .swipeActions(edge: .trailing) {
            Button {
                showConfirmationDialog.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading) {
            Button {
                if let editFunc = onEdit {
                    editFunc(category)
                }
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.indigo)
        }
        .confirmationDialog("Are you sure you want to delete \(category.wrappedName)?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let deleteFunc = onDelete {
                    withAnimation(.easeInOut) {
                        deleteFunc(category)
                    }
                }
            }
        } message: {
            Text("\(category.wrappedTransactionsCount) related transactions will be deleted.")
        }
    }
}

struct TransactionCategoryListTile_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryListTile(category: TransactionCategory())
    }
}
