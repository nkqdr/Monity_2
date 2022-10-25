//
//  SettingsSavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SavingsView: View {
    
    @ViewBuilder
    func savingsCategoriesHeader(_ createFunc: @escaping () -> Void) -> some View {
        HStack {
            Text("Categories")
            Spacer()
            Button(action: createFunc) {
                Image(systemName: "plus")
            }
        }
    }
    
    var savingsCategoriesFooter: some View {
        Text("Here you can add all of your savings categories, so that you can later add entries to these categories.")
    }
    
    var body: some View {
        EditableDeletableItemList(viewModel: SettingsSavingsViewModel()) { items, createFunc, editFunc, deleteFunc in
            Section(header: savingsCategoriesHeader(createFunc), footer: savingsCategoriesFooter) {
                ForEach(items) { category in
                    SavingsCategoryTile(
                        category: category,
                        onEdit: editFunc,
                        onDelete: deleteFunc
                    )
                }
            }
        } sheetContent: { showAddSheet, currentItem in
            SavingsCategoryFormView(
                isPresented: showAddSheet,
                editor: SavingsCategoryEditor(category: currentItem)
            )
        }
        .navigationTitle("Savings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Settings_SavingsView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_SavingsView()
    }
}
