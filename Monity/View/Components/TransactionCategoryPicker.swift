//
//  TransactionCategoryPicker.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import SwiftUI

struct TransactionCategoryPicker: View {
    @FetchRequest(
        entity: TransactionCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
    ) private var allCategories: FetchedResults<TransactionCategory>
    @Binding var selection: TransactionCategory?
    
    var body: some View {
        Picker("Category", selection: $selection) {
            Text("None").tag(Optional<TransactionCategory>.none)
            ForEach(allCategories) { category in
                Group {
                    if let icon = category.iconName {
                        Label(category.wrappedName, systemImage: icon)
                    } else {
                        Text(category.wrappedName)
                    }
                }
                .tag(category as TransactionCategory?)
            }
        }
    }
}

struct TransactionCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryPicker(selection: .constant(nil))
    }
}
