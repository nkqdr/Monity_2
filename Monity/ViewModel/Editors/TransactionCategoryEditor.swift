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
    @Published var disableSave: Bool = true
    @Published var selectedIcon: String?
    private var allCategories: [TransactionCategory]
    var category: TransactionCategory?
    
    var isValid: Bool {
        let nameIsValid: Bool = self.name != ""
        let nameIsDirty: Bool = category == nil ? true : category?.wrappedName != self.name
        let iconIsDirty: Bool = category == nil ? true : category?.iconName != self.selectedIcon
        
        return nameIsValid && (nameIsDirty || iconIsDirty)
    }
    
    init(category: TransactionCategory? = nil) {
        self.name = category?.wrappedName ?? ""
        self.category = category
        self.selectedIcon = category?.iconName
        let fetchRequest = TransactionCategory.fetchRequest()
        let categories = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        self.allCategories = categories ?? []
    }
    
    // MARK: - Intent
    
    public func save() {
        if let c = category {
            let res = TransactionCategoryStorage.main.update(c, name: name, iconName: selectedIcon)
        } else {
            let category = TransactionCategoryStorage.main.add(name: name, iconName: selectedIcon)
            print("Added category \(category.wrappedName)")
        }
    }
}
