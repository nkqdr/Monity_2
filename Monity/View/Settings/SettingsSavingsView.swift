//
//  SettingsSavingsView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SavingsView: View {
    @State private var showAddCategorySheet: Bool = false
    
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
            
        }
    }
    
    var body: some View {
        List {
            savingsCategories
        }
        .sheet(isPresented: $showAddCategorySheet) {
            Text("Yeet")
                .presentationDetents([.medium, .large])
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
