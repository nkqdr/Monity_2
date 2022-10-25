//
//  SettingsSavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SavingsView: View {
    @State private var showAddCategorySheet: Bool = false
    @StateObject private var content = SettingsSavingsViewModel()
    
    func showEditSheetForCategory(_ category: SavingsCategory) {
        content.currentCategory = category
        showAddCategorySheet.toggle()
    }
    
    var savingsCategories: some View {
        Section(header: HStack {
            Text("Categories")
                    Spacer()
                    Button {
                        showAddCategorySheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
        }, footer: Text("Here you can add all of your savings categories, so that you can later add entries to these categories.")) {
            ForEach(content.categories) { category in
                SavingsCategoryTile(category: category, onEdit: showEditSheetForCategory, onDelete: content.deleteCategory)
            }
        }
    }
    
    var body: some View {
        List {
            savingsCategories
        }
        .sheet(isPresented: $showAddCategorySheet) {
            SavingsCategoryFormView(isPresented: $showAddCategorySheet, editor: SavingsCategoryEditor(category: content.currentCategory))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: showAddCategorySheet) { newValue in
            if !newValue {
                content.currentCategory = nil
            }
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
