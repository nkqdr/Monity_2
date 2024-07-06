//
//  View+CustomNavigationDestination.swift
//  Monity
//
//  Created by Niklas Kuder on 06.07.24.
//

import SwiftUI

fileprivate struct CustomNavigationDestinationModifier<D, C>: ViewModifier where D : Hashable, C : View {
    @State private var isPresented: Bool
    @Binding private var item: D?
    @ViewBuilder private var destination: (D) -> C
    
    init(item: Binding<Optional<D>>, destination: @escaping (D) -> C) {
        self._isPresented = State(initialValue: item.wrappedValue != nil)
        self._item = item
        self.destination = destination
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(isPresented: $isPresented) {
            if let d = self.item {
                destination(d)
            }
        }
        .onChange(of: item) { newValue in
            self.isPresented = newValue != nil
        }
        .onChange(of: isPresented) { newValue in
            if !isPresented {
                item = nil
            }
        }
    }
}

extension View {
    func customNavigationDestination<D, C>(
        item: Binding<Optional<D>>,
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View where D : Hashable, C : View {
        self.modifier(
            CustomNavigationDestinationModifier(item: item, destination: destination)
        )
    }
}
