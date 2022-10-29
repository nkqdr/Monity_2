//
//  SettingsSavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SavingsView: View {
    @ObservedObject var content = SettingsSavingsViewModel()
    
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
        EditableDeletableItemList(viewModel: content) { create, edit, delete in
            Section(header: savingsCategoriesHeader(create), footer: savingsCategoriesFooter) {
                ForEach(content.items) { category in
                    EditableDeletableItem(
                        item: category,
                        confirmationTitle: "Are you sure you want to delete \(category.wrappedName)?",
                        confirmationMessage: "\(category.wrappedEntryCount) related entries will be deleted.",
                        onEdit: edit,
                        onDelete: delete) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.wrappedName)
                                    Text("Associated entries: \(item.entries?.count ?? 0)")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(LocalizedStringKey(item.wrappedLabel))
                                    .foregroundColor(.secondary)
                                Circle()
                                    .foregroundColor(item.color)
                                    .frame(width: 14)
                            }
                        }
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
