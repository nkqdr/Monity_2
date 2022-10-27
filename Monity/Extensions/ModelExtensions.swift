//
//  ModelExtensions.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import SwiftUI

extension TransactionCategory {
    var wrappedName: String {
        self.name ?? ""
    }
    
    var wrappedTransactionsCount: Int {
        self.transactions?.count ?? 0
    }
}

extension Transaction {
    var wrappedText: String {
        self.text ?? ""
    }
}

extension SavingsCategory {
    var wrappedName: String {
        self.name ?? ""
    }
    
    var color: Color {
        for category in SavingsCategoryLabel.allCases {
            if category.rawValue == self.label {
                return category.color
            }
        }
        return Color.clear
    }
    
    var wrappedEntryCount: Int {
        self.entries?.count ?? 0
    }
    
    public var entryArray: [SavingsEntry] {
        let set = entries as? Set<SavingsEntry> ?? []
        
        return set.sorted {
            return $0.wrappedDate < $1.wrappedDate
        }
    }
    
    var lastEntry: SavingsEntry? {
        self.entryArray.last
    }
}

extension SavingsEntry {
    var wrappedDate: Date {
        self.date ?? Date()
    }
}
