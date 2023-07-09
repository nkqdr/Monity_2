//
//  AbstractTransactionWrapper.swift
//  Monity
//
//  Created by Niklas Kuder on 07.04.23.
//

import Foundation
import Combine

extension UserDefaults {
    @objc dynamic var integrate_recurring_expenses_in_month_overview: Bool {
        return bool(forKey: AppStorageKeys.integrateRecurringExpensesInCalculations)
    }
}

class AbstractTransactionWrapper: ObservableObject {
    @Published var wrappedTransactions: [AbstractTransaction] = []
    /// All recorded expenses in the selected month
    private var transactions: [Transaction] = [] {
        didSet {
            self.wrappedTransactions = calcWrappedTransactions()
        }
    }
    /// All recurring transactions that are active in the selected month
    private var recurringExpenses: [RecurringTransaction] = [] {
        didSet {
            self.wrappedTransactions = calcWrappedTransactions()
        }
    }
    /// Setting that enables/disables the inclusion of recurring transactions in the monthly overview
    private var includeRecurringExpenses: Bool = UserDefaults.standard.bool(forKey: AppStorageKeys.integrateRecurringExpensesInCalculations) {
        didSet {
            self.wrappedTransactions = calcWrappedTransactions()
        }
    }
    
    private var startOfTimeframe: Date
    private var endOfTimeframe: Date
    
    
    var transactionCancellable: AnyCancellable?
    var recurringTransactionCancellable: AnyCancellable?
    var includeRecurringCancellable: AnyCancellable?
    private var fetchController: TransactionFetchController
    private var recurringFetchController: RecurringTransactionFetchController
    
    // MARK: - Initializers
    
    /// If this initializer is used, {wrappedTransactions} will contain all Transactions that have ever been recorded
    convenience init() {
        self.init(
            transactionController: TransactionFetchController.all,
            recurringTransactionController: RecurringTransactionFetchController.all
        )
    }
    
    /// If this initializer is used, {wrappedTransactions} will contain only the transactions in the specified month
    convenience init(date: Date) {
        let selectedMonthComps = Calendar.current.dateComponents([.month, .year], from: date)
        self.init(
            transactionController: TransactionFetchController(month: selectedMonthComps.month, year: selectedMonthComps.year),
            recurringTransactionController: RecurringTransactionFetchController(date: date),
            startTimeframe: date.removeTimeStampAndDay ?? date,
            endTimeframe: Calendar.current.date(byAdding: DateComponents(month: 1), to: date)?.removeTimeStampAndDay ?? date
        )
    }
    
    convenience init(startDate: Date, endDate: Date) {
        self.init(
            transactionController: TransactionFetchController(start: startDate, end: endDate),
            recurringTransactionController: RecurringTransactionFetchController(startDate: startDate, endDate: endDate),
            startTimeframe: startDate,
            endTimeframe: endDate
        )
    }
    
    public init(transactionController: TransactionFetchController, recurringTransactionController: RecurringTransactionFetchController, startTimeframe: Date = Date.distantPast, endTimeframe: Date = Date.distantFuture) {
        self.fetchController = transactionController
        self.recurringFetchController = recurringTransactionController
        self.startOfTimeframe = startTimeframe
        self.endOfTimeframe = endTimeframe
        
        let includeRecurringPublisher = UserDefaults.standard.publisher(for: \.integrate_recurring_expenses_in_month_overview)
        self.includeRecurringCancellable = includeRecurringPublisher.sink { value in
            self.includeRecurringExpenses = value
        }
        let transactionPublisher = self.fetchController.items.eraseToAnyPublisher()
        self.transactionCancellable = transactionPublisher.sink { value in
            self.transactions = value
        }
        let recurringTransactionPublisher = self.recurringFetchController.items.eraseToAnyPublisher()
        self.recurringTransactionCancellable = recurringTransactionPublisher.sink { value in
            self.recurringExpenses = value
        }
    }
    
    // MARK: - Helper functions
    
    private func calcWrappedTransactions() -> [AbstractTransaction] {
        let abstractTransactions = self.transactions.map { AbstractTransaction(date: $0.date, category: $0.category, amount: $0.amount, isExpense: $0.isExpense) }
        guard self.includeRecurringExpenses else {
            // If recurring expenses should not be included, the wrapped transactions just equal the regular transactions
            return abstractTransactions
        }
        
        // Otherwise, also include the recurring expenses as AbstractTransactions
        let abstractRecurringTransactions: [AbstractTransaction] = self.recurringExpenses.map { recExpense in
            return recExpense.individualTransactions.filter{
                guard let date = $0.date else { return false }
                return date >= self.startOfTimeframe && date <= self.endOfTimeframe
            }
        }.reduce([], +)
        
        return abstractTransactions + abstractRecurringTransactions
    }
}
