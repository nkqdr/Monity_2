//
//  Structures.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import Accelerate
import SwiftUI

struct PieChartDataPoint: Identifiable {
    var id: UUID = UUID()
    var title: LocalizedStringKey
    var value: Double
    var color: Color
}

struct TransactionsByDate: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var transactions: [Transaction]
    
    mutating func setTransactions(_ newTransactions: [Transaction]) {
        transactions = newTransactions
    }
}

struct ValueTimeDataPoint: Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var value: Double
    var animate: Bool = false
    
    var description: String {
        return "\(date) -> \(value)"
    }
}

struct AssetAllocationDataPoint: Identifiable {
    var id = UUID()
    var category: SavingsCategory
    var totalAmount: Double
    var relativeAmount: Double
}

struct ImportCSVSummary: Identifiable, Equatable {
    struct CSVRow: Identifiable, Equatable {
        var id = UUID()
        var rowContent: String
    }
    var id: UUID = UUID()
    var resource: CSVValidHeaders
    var rowsAmount: Int
    var rows: [CSVRow]
    
    var resourceName: LocalizedStringKey {
        self.resource.resourceName
    }
}

struct AbstractTransaction {
    var date: Date?
    var category: TransactionCategory?
    var amount: Double
    var isExpense: Bool
    
    var wrappedDate: Date {
        date ?? Date()
    }
}
