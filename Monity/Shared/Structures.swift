//
//  Structures.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import SwiftUI

enum SavingsCategoryLabel: String, CaseIterable {
    case liquid = "Liquid"
    case saved = "Saved"
    case invested = "Invested"
    case none = ""
    
    var color: Color {
        switch self {
        case .none: return Color.clear
        case .saved: return Color.yellow
        case .invested: return Color.green
        case .liquid: return Color.blue
        }
    }
    
    static var allCasesWithoutNone: [SavingsCategoryLabel] {
        var cases = self.allCases
        let removed = cases.removeLast()
        if removed != .none {
            fatalError("The wrong label got removed.")
        }
        return cases
    }
    
    static func by(_ repr: String?) -> SavingsCategoryLabel {
        for label in SavingsCategoryLabel.allCases {
            if label.rawValue == repr {
                return label
            }
        }
        return SavingsCategoryLabel.none
    }
}

struct PieChartDataPoint: Identifiable {
    var id: UUID = UUID()
    var title: LocalizedStringKey
    var value: Double
    var color: Color
}

struct TransactionsByDate: Identifiable {
    var id = UUID()
    var date: Date
    var transactions: [Transaction]
    
    mutating func setTransactions(_ newTransactions: [Transaction]) {
        transactions = newTransactions
    }
}

struct CategoryRetroDataPoint: Identifiable, Equatable {
    var id: UUID = UUID()
    var category: TransactionCategory
    var total: Double
    var average: Double
    var numTransactions: Int
    
    mutating func setTotal(_ newTotal: Double) {
        total = newTotal
    }
    
    mutating func setAverage(_ avg: Double) {
        average = avg
    }
    
    mutating func setNumTransactinos(_ num: Int) {
        numTransactions = num
    }
}

struct ValueTimeDataPoint: Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var value: Double
    
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
    var id: UUID = UUID()
    var resource: CSVValidHeaders
    var rowsAmount: Int
    var rows: [String]
    
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
