//
//  CategoryRetroDataPoint.swift
//  Monity
//
//  Created by Niklas Kuder on 30.06.24.
//

import Foundation
import Accelerate

struct CategoryRetroDataPoint: Identifiable, Equatable {
    var id: UUID = UUID()
    var category: TransactionCategory
    var timeframe: Timeframe
    var isForExpenses: Bool
    var total: Double
    var average: Double
    var numTransactions: Int
    
    init(category: TransactionCategory, timeframe: Timeframe, isForExpenses: Bool) {
        self.category = category
        self.timeframe = timeframe
        self.isForExpenses = isForExpenses
        let fetchController = AbstractTransactionWrapper(
            startDate: timeframe.startDate ?? Date(),
            category: category
        )
        let transactions = fetchController.wrappedTransactions.filter {
            $0.isExpense == isForExpenses
        }
        self.total = vDSP.sum(
            transactions.map { $0.amount }
        )
        self.average = vDSP.mean(
            transactions.map { $0.amount }
        )
        self.numTransactions = transactions.count
    }
}

