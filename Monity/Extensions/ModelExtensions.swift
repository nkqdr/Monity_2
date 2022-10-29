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
    
    var wrappedLabel: String {
        self.label ?? ""
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
    
    func lastEntryBefore(_ date: Date) -> SavingsEntry? {
        let entriesBefore = self.entryArray.filter { $0.wrappedDate.removeTimeStamp ?? Date() <= date }
        return entriesBefore.last
    }
    
    var lastEntry: SavingsEntry? {
        self.entryArray.last
    }
    
    func lineChartDataPoints(after: Date) -> [ValueTimeDataPoint] {
        let data =  self.entryArray.filter { $0.wrappedDate >= after }.map { ValueTimeDataPoint(date: $0.wrappedDate, value: $0.amount) }.sorted {
            $0.date < $1.date
        }
        return data
    }
}

extension SavingsEntry {
    var wrappedDate: Date {
        self.date ?? Date()
    }
}
