//
//  ViewExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import SwiftUI

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
}
