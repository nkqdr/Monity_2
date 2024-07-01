//
//  CategoryRetroDataPoint.swift
//  Monity
//
//  Created by Niklas Kuder on 30.06.24.
//

import Foundation
import Accelerate
import Combine

class CategoryRetroDataPoint: ObservableObject, Identifiable {
    var id = UUID()
    var timeframe: Timeframe
    var isForExpenses: Bool
    @Published var category: TransactionCategory
    @Published var total: Double = 0
    @Published var average: Double = 0
    @Published var numTransactions: Int = 0
    
    private var transactionCancellable: AnyCancellable?
    private var abstractTransactionWrapper: AbstractTransactionWrapper
    
    init(
        category: TransactionCategory,
        timeframe: Timeframe,
        isForExpenses: Bool,
        controller: PersistenceController = PersistenceController.shared
    ) {
        self.category = category
        self.timeframe = timeframe
        self.isForExpenses = isForExpenses
        let startDate = timeframe.startDate ?? Date()
        self.abstractTransactionWrapper = AbstractTransactionWrapper(
            startDate: startDate,
            category: category,
            controller: controller
        )
        let publisher = self.abstractTransactionWrapper.$wrappedTransactions.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { transactions in
            let filteredTransactions = transactions.filter { $0.isExpense == isForExpenses }
            self.total = vDSP.sum(
                filteredTransactions.map { $0.amount }
            )
            self.average = vDSP.mean(
                filteredTransactions.map { $0.amount }
            )
            self.numTransactions = filteredTransactions.count
        }
    }
}

