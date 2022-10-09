//
//  TransactionCategoryEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation

class AddTransactionCategoryViewModel: ObservableObject {
    @Published var name: String = ""
    
    // MARK: - Intents
    
    public func save() {
        let category = TransactionCategoryStorage.shared.add(name: name)
        print("Added category \(category.name ?? "")")
    }
}
