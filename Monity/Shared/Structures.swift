//
//  Structures.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import SwiftUI

enum SavingsCategoryLabel: String, CaseIterable {
    case none = ""
    case saved = "Saved"
    case invested = "Invested"
    case liquid = "Liquid"
    
    var color: Color {
        switch self {
        case .none: return Color.clear
        case .saved: return Color.yellow
        case .invested: return Color.green
        case .liquid: return Color.blue
        }
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
    var title: String
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
}

struct ImportCSVSummary: Identifiable, Equatable {
    var id: UUID = UUID()
    var resourceName: LocalizedStringKey
    var rowsAmount: Int
    var rows: [String]
}
