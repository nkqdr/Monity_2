//
//  View+SavingsCategoryControls.swift
//  Monity
//
//  Created by Niklas Kuder on 04.07.24.
//

import SwiftUI

fileprivate struct AddSavingsCategorySheet: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            SavingsCategoryFormView(editor: SavingsCategoryEditor())
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.hidden)
        }
    }
}

fileprivate struct EditSavingsCategorySheet: ViewModifier {
    @Binding var category: SavingsCategory?
    
    func body(content: Content) -> some View {
        content.sheet(item: $category) { category in
            SavingsCategoryFormView(editor: SavingsCategoryEditor(category: category))
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.hidden)
        }
    }
}


extension View {
    func addSavingsCategorySheet(isPresented: Binding<Bool>) -> some View {
        self.modifier(AddSavingsCategorySheet(isPresented: isPresented))
    }
    
    func editSavingsCategorySheet(category: Binding<SavingsCategory?>) -> some View {
        self.modifier(EditSavingsCategorySheet(category: category))
    }
}
