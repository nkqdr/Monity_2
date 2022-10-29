//
//  TransactionCategoryEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import SwiftUI

class TransactionCategoryEditor: ObservableObject {
    @Published var name: String {
        didSet {
            disableSave = allCategories.map { $0.wrappedName }.contains(name) || name == ""
        }
    }
    @Published var navigationFormTitle: LocalizedStringKey
    @Published var disableSave: Bool = true
    private var allCategories: [TransactionCategory]
    var category: TransactionCategory?
    
    init(category: TransactionCategory? = nil) {
        self.name = category?.wrappedName ?? ""
        self.navigationFormTitle = (category != nil) ? "Edit category" : "New category"
        self.category = category
        let fetchRequest = TransactionCategory.fetchRequest()
        let categories = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        self.allCategories = categories ?? []
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
