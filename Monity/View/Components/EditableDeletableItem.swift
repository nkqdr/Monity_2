//
//  EditableDeletableItem.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import SwiftUI

struct EditableDeletableItem<ItemType, Content>: View where Content: View {
    @State private var showConfirmationDialog: Bool = false
    var item: ItemType
    var confirmationTitle: LocalizedStringKey
    var confirmationMessage: LocalizedStringKey?
    var onEdit: ((ItemType) -> Void)?
    var onDelete: ((ItemType) -> Void)?
    var content: (ItemType) -> Content
    
    var body: some View {
        content(item)
            .deleteSwipeAction {
                showConfirmationDialog.toggle()
            }
            .editSwipeAction {
                if let editFunc = onEdit {
                    editFunc(item)
                }
            }
            .contextMenu {
                if let editFunc = onEdit {
                    Button {
                        editFunc(item)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                if let deleteFunc = onDelete {
                    Button(role: .destructive) {
                        showConfirmationDialog.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .confirmationDialog(confirmationTitle, isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let deleteFunc = onDelete {
                        withAnimation(.easeInOut) {
                            deleteFunc(item)
                        }
                    }
                }
            } message: {
                if let msg = confirmationMessage {
                    Text(msg)
                }
            }
    }
}
