//
//  TransactionCategoryEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation

class TransactionCategoryEditor: ObservableObject {
    @Published var name: String
    @Published var navigationFormTitle: String
    var category: TransactionCategory?
    
    init(category: TransactionCategory? = nil) {
        self.name = category?.wrappedName ?? ""
        self.navigationFormTitle = (category != nil) ? "Edit category" : "New category"
        self.category = category
    }
    
    // MARK: - Intent
    
    public func save() {
        if let c = category {
            let res = TransactionCategoryStorage.shared.update(c, name: name)
            print(res)
        } else {
            let category = TransactionCategoryStorage.shared.add(name: name)
            print("Added category \(category.wrappedName)")
        }
    }
}
