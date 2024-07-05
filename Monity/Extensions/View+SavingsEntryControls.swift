//
//  View+SavingsEntryControls.swift
//  Monity
//
//  Created by Niklas Kuder on 04.07.24.
//

import SwiftUI

fileprivate struct AddSavingsEntrySheet: ViewModifier {
    @Binding var category: SavingsCategory?
    
    func body(content: Content) -> some View {
        content.sheet(item: $category) { category in
            SavingsEntryFormView(editor: SavingsEditor(category: category))
                .presentationDetents([.height(240)])
                .presentationDragIndicator(.hidden)
        }
    }
}

fileprivate struct EditSavingsEntrySheet: ViewModifier {
    @Binding var entry: SavingsEntry?
    
    func body(content: Content) -> some View {
        content.sheet(item: $entry) { entry in
            SavingsEntryFormView(editor: SavingsEditor(entry: entry))
                .presentationDetents([.height(240)])
                .presentationDragIndicator(.hidden)
        }
    }
}


extension View {
    func addSavingsEntrySheet(category: Binding<SavingsCategory?>) -> some View {
        self.modifier(AddSavingsEntrySheet(category: category))
    }
    
    func editSavingsEntrySheet(entry: Binding<SavingsEntry?>) -> some View {
        self.modifier(EditSavingsEntrySheet(entry: entry))
    }
}
