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
    
    var wrappedDate: Date {
        self.date ?? Date()
    }
}

extension Transaction: CSVRepresentable {
    private var wrappedCSVText: String {
        if self.wrappedText.contains(",") {
            return "\"\(self.wrappedText)\""
        }
        return self.wrappedText
    }
    
    private var wrappedCategoryCSVName: String {
        let name = self.category?.wrappedName ?? ""
        if name.contains(",") {
            return "\"\(name)\""
        }
        return name
    }
    
    private var expenseTypeString: String {
        self.isExpense ? "expense" : "income"
    }
    
    var commaSeparatedString: String {
        "\(self.wrappedCSVText),\(self.amount),\(Utils.formatDateToISOString(self.wrappedDate)),\(self.expenseTypeString),\(self.wrappedCategoryCSVName)"
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

extension SavingsEntry: CSVRepresentable {
    private var wrappedCSVcategoryName: String {
        let name = self.category?.wrappedName ?? ""
        if name.contains(",") {
            return "\"\(name)\""
        }
        return name
    }
    
    var commaSeparatedString: String {
        "\(self.amount),\(Utils.formatDateToISOString(self.wrappedDate)),\(self.wrappedCSVcategoryName),\(self.category?.wrappedLabel ?? "")"
    }
}

extension RecurringTransaction {
    var wrappedName: String {
        self.name ?? ""
    }
    
    var isActive: Bool {
        self.endDate == nil
    }
    
    var normalizedMonthlyAmount: Double {
        guard let monthDivider = TransactionCycle.fromValue(self.cycle)?.dividerForMonthlyValue else {
            return 0
        }
        return (self.amount / monthDivider)
    }
    
    var individualTransactions: [AbstractTransaction] {
        guard let start = self.startDate else {
            return []
        }
        return Date.getMonthAndYearBetween(from: start, to: self.endDate ?? Date()).map { AbstractTransaction(date: $0, category: self.category, amount: self.normalizedMonthlyAmount, isExpense: true) }
    }
    
    func isActiveAt(date: Date) -> Bool {
        guard let startDate = self.startDate?.removeTimeStamp else {
            return false
        }
        guard let endDate = self.endDate?.removeTimeStamp else {
            return startDate <= date
        }
        return startDate <= date && date < endDate
    }
}
