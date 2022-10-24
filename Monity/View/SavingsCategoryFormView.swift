//
//  SavingsCategoryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import SwiftUI

struct SavingsCategoryFormView: View {
    @Binding var isPresented: Bool
    @StateObject var editor: SavingsCategoryEditor
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $editor.name)
                Picker("Label", selection: $editor.label) {
                    Text("None").tag(SavingsCategoryLabel.none)
                    Text("Liquid").tag(SavingsCategoryLabel.liquid)
                    Text("Saved").tag(SavingsCategoryLabel.saved)
                    Text("Invested").tag(SavingsCategoryLabel.invested)
                }
            }
            .navigationTitle(editor.navigationFormTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        editor.save()
                        isPresented = false
                    }
                    .disabled(editor.disableSave)
                }
            }
        }
    }
}

struct SavingsCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        SavingsCategoryFormView(isPresented: .constant(true), editor: SavingsCategoryEditor())
    }
}
