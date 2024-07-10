//
//  SavingsEditor.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import Foundation
import SwiftUI

class SavingsEditor: ObservableObject {
    @Published var category: SavingsCategory?
    @Published var amount: Double?
    @Published var disableSave: Bool = true
    @Published var navigationFormTitle: LocalizedStringKey
    @Published var timestamp: Date
    var entry: SavingsEntry?
    
    var isValid: Bool {
        amount != nil && category != nil
    }
    
    init(entry: SavingsEntry? = nil) {
        self.category = entry?.category
        self.amount = entry?.amount ?? nil
        self.timestamp = entry?.date ?? Date()
        self.navigationFormTitle = (entry != nil) ? "Edit entry" : "New entry"
        self.entry = entry
        if entry != nil {
            disableSave = false
        }
    }
    
    init(category: SavingsCategory? = nil) {
        self.category = category
        self.amount = nil
        self.timestamp = Date()
        self.navigationFormTitle = "New entry"
        self.entry = nil
    }
    
    // MARK: - Intent
    
    public func save() {
        if let entry {
            let _ = SavingStorage.main.update(entry, editor: self)
        } else if let amount {
            let entry = SavingStorage.main.add(amount: amount, category: category)
            print("Added entry \(entry.wrappedDate)")
        }
    }
}
