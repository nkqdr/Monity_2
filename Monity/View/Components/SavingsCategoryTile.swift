//
//  SavingsCategoryTile.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import SwiftUI

struct SavingsCategoryTile: View {
    @State private var showConfirmationDialog: Bool = false
    var category: SavingsCategory
    var onEdit: ((SavingsCategory) -> Void)?
    var onDelete: ((SavingsCategory) -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.wrappedName)
                Text("Associated entries: \(category.entries?.count ?? 0)")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(category.label?.description ?? "")
                .foregroundColor(.secondary)
            Circle()
                .foregroundColor(category.color)
                .frame(width: 14)
        }
        .deleteSwipeAction {
            showConfirmationDialog.toggle()
        }
        .editSwipeAction {
            if let editFunc = onEdit {
                editFunc(category)
            }
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
            Text("\(category.wrappedEntryCount) related entries will be deleted.")
        }
    }
}
