//
//  MonthCashflowCalculator.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import Foundation
import Combine

class MonthCashflowCalculator: ObservableObject {
    @Published var cashFlowData: [ValueTimeDataPoint] = []
    
    private var transactions: [AbstractTransaction] = [] {
        didSet {
            let startOfMonthDate: Date = selectedDate.startOfThisMonth
            self.cashFlowData = LineChartDataBuilder.generateCashflowData(for: transactions, initialDate: startOfMonthDate)
        }
    }
    private var selectedDate: Date
    private var transactionCancellable: AnyCancellable?
    
    init(date: Date = Date()) {
        self.selectedDate = date
        let transactionPublisher = AbstractTransactionWrapper(date: date).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { value in
            self.transactions = value
        }
    }
}
