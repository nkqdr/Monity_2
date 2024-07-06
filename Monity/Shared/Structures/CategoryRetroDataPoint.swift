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
    var isForExpenses: Bool?
    @Published var category: TransactionCategory
    @Published var total: Double = 0
    @Published var averagePerMonth: Double = 0
    @Published var numTransactions: Int = 0
    
    private var transactionCancellable: AnyCancellable?
    private var abstractTransactionWrapper: AbstractTransactionWrapper
    
    init(
        category: TransactionCategory,
        timeframe: Timeframe,
        isForExpenses: Bool? = nil,
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
            var filteredTransactions = transactions
            if let isForExpenses {
                filteredTransactions = transactions.filter { $0.isExpense == isForExpenses }
            }
            
            
            self.total = vDSP.sum(
                filteredTransactions.map { $0.amount }
            )
            self.numTransactions = filteredTransactions.count
            
            if let numMonths = timeframe.numMonths {
                self.averagePerMonth = self.total / Double(numMonths)
            } else if timeframe == .total {
                let sortedByDate = filteredTransactions.sorted {
                    $0.wrappedDate < $1.wrappedDate
                }
                let firstTransactionDate: Date? = sortedByDate.first?.date
                if firstTransactionDate == nil {
                    self.averagePerMonth = 0
                    return
                }
                
                let comps = Calendar.current.dateComponents([.month], 
                                                            from: firstTransactionDate!, to: Date())
                self.averagePerMonth = self.total / Double(comps.month ?? 1)
            } else {
                // The calendar failed to calculate a range
                self.averagePerMonth = 0
            }
        }
    }
}

