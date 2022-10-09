//
//  TransactionCategoryFormView.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import SwiftUI

struct TransactionCategoryFormView: View {
    @Binding var isPresented: Bool
    @StateObject private var editor = AddTransactionCategoryViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $editor.name)
            }
            .navigationTitle("New category")
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
                }
            }
        }
    }
}

struct TransactionCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryFormView(isPresented: .constant(true))
    }
}
