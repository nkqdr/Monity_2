//
//  ViewExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

enum GroupBoxLabelStyle {
    case primary
    case secondary
}

extension View {
    func deleteSwipeAction(callback: @escaping () -> Void) -> some View {
        self.swipeActions(edge: .trailing) {
            Button(action: callback) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
    
    func editSwipeAction(callback: @escaping () -> Void) -> some View {
        self.swipeActions(edge: .leading) {
            Button(action: callback) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.indigo)
        }
    }
    
    func sync<T:Equatable>(_ published:Binding<T>, with binding:Binding<T>) -> some View{
        self
            .onChange(of: published.wrappedValue) { published in
                binding.wrappedValue = published
            }
            .onChange(of: binding.wrappedValue) { binding in
                published.wrappedValue = binding
            }
    }
    
    @ViewBuilder
    func groupBoxLabelTextStyle(_ style: GroupBoxLabelStyle = .primary) -> some View {
        switch style {
        case .primary:
            self.font(.headline).bold()
        case .secondary:
            self.font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    func onlyHideContextMenu<T: View>(@ViewBuilder content: @escaping () -> T) -> some View {
        self.contextMenu {
            Button {
                // Do nothing because contextMenu closes automatically
            } label: {
                Label("Hide", systemImage: "eye.slash.fill")
            }
        } preview: {
            content()
        }
    }
}
