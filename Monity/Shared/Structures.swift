//
//  Structures.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import Foundation
import SwiftUI

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
