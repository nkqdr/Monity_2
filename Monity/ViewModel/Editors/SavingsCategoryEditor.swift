//
//  SavingsCategoryEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import SwiftUI

class SavingsCategoryEditor: ObservableObject {
    @Published var name: String {
        didSet {
            disableSave = shouldDisableSave()
        }
    }
    @Published var label: SavingsCategoryLabel {
        didSet {
            disableSave = shouldDisableSave()
        }
    }
    @Published var navigationFormTitle: LocalizedStringKey
    @Published var disableSave: Bool = true
    @Published var interestRate: Double
    private var allCategories: [SavingsCategory]
    var category: SavingsCategory?
    
    init(category: SavingsCategory? = nil) {
        self.name = category?.name ?? ""
        self.label = SavingsCategoryLabel.by(category?.label)
        self.navigationFormTitle = (category != nil) ? "Edit category" : "New category"
        self.category = category
        let fetchRequest = SavingsCategory.fetchRequest()
        let categories = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        self.allCategories = categories ?? []
        self.interestRate = category?.interestRate ?? 0
    }
    
    private func shouldDisableSave() -> Bool {
        let nameExistsElsewhere: Bool = allCategories.filter { $0.id != category?.id }.map { $0.wrappedName }.contains(name)
        return nameExistsElsewhere || name == ""
    }
    
    // MARK: - Intent
    
    public func save() {
        if let category {
            let _ = SavingsCategoryStorage.main.update(category, name: name, label: label, interestRate: interestRate)
        } else {
            let category = SavingsCategoryStorage.main.add(name: name, label: label, interestRate: interestRate)
            print("Added category \(category.wrappedName)")
        }
    }
}
