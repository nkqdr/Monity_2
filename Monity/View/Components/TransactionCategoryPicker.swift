//
//  TransactionCategoryPicker.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI

struct TransactionCategoryPicker: View {
    @Binding var selection: TransactionCategory?
    @State private var allCategories: [TransactionCategory] = []
    
    var body: some View {
        Picker("Choose a category", selection: $selection) {
            Text("None").tag(Optional<TransactionCategory>.none)
            ForEach(allCategories) { category in
                Text(category.wrappedName).tag(category as TransactionCategory?)
            }
        }.onReceive(TransactionCategoryFetchController.all.items.eraseToAnyPublisher()) { categories in
            allCategories = categories
        }
    }
}

struct TransactionCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryPicker(selection: .constant(nil))
    }
}
