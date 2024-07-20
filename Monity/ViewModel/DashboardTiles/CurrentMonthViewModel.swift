//
//  CurrentMonthViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import Foundation
import Combine
import Accelerate

class CurrentMonthViewModel: ObservableObject {
    @Published var remainingDays: Int = 0
    @Published var predictedTotalSpendings: Double = 0
    @Published var spendingsPerDay: Double = 0
    @Published var spentThisMonth: Double = 0
    @Published var selectedDate: DateComponents
    @Published var currentMonthlyLimit: Double?
    @Published var remainingAmount: Double?
    private let currentComps: DateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    
    var currentMonthSelected: Bool {
        selectedDate.toDate.isSameMonthAs(Date())
    }
    private var transactionCancellable: AnyCancellable?
    private var budgetCancellable: AnyCancellable?
    private var budgetFetchController: MonthlyBudgetFetchController
    
    public init() {
        let now = Date()
        self.selectedDate = Calendar.current.dateComponents([.year, .month], from: now)
        self.remainingDays = Calendar.current.numberOfDaysBetween(now, and: now.endOfThisMonth) + 1
        
        self.budgetFetchController = MonthlyBudgetFetchController()
        let budgetPublisher = self.budgetFetchController.items.eraseToAnyPublisher()
        self.budgetCancellable = budgetPublisher.sink { budgets in
            if let b = budgets.first, b.amount != 0 {
                self.currentMonthlyLimit = b.amount
            } else {
                self.currentMonthlyLimit = nil
            }
            self.calculateRemainingAmount()
        }
        
        let publisher = AbstractTransactionWrapper(
            date: now
        ).$wrappedTransactions.eraseToAnyPublisher()
        self.transactionCancellable = publisher.sink { items in
            let now = Date()
            self.spentThisMonth = vDSP.sum(items.filter { $0.isExpense }.map { $0.amount })
            
            let currentDay: Int = Calendar.current.dateComponents([.day], from: now).day ?? 1
            self.spendingsPerDay = self.spentThisMonth / Double(currentDay)
            
            let daysInMonth: Int = Calendar.current.range(
                of: .day, in: .month, for: now)?.count ?? 0
            self.predictedTotalSpendings = self.spendingsPerDay * Double(daysInMonth)
            self.calculateRemainingAmount()
        }
    }
    
    private func calculateRemainingAmount() {
        guard let limit = self.currentMonthlyLimit else {
            self.remainingAmount = nil
            return
        }
        self.remainingAmount = limit - self.spentThisMonth
    }
}
