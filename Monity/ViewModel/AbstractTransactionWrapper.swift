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
    private var selectedMonthDate: Date? = nil
    /// All recorded expenses in the selected month
    private var transactions: [Transaction] = [] {
        didSet {
            update()
        }
    }
    /// All recurring transactions that are active in the selected month
    private var recurringExpenses: [RecurringTransaction] = [] {
        didSet {
            update()
        }
    }
    /// Setting that enables/disables the inclusion of recurring transactions in the monthly overview
    private var includeRecurringExpenses: Bool = UserDefaults.standard.bool(forKey: AppStorageKeys.integrateRecurringExpensesInCalculations) {
        didSet {
            update()
        }
    }
    var transactionCancellable: AnyCancellable?
    var recurringTransactionCancellable: AnyCancellable?
    var includeRecurringCancellable: AnyCancellable?
    private var fetchController: TransactionFetchController
    
    /// If this initializer is used, {wrappedTransactions} will contain all Transactions that have ever been recorded
    init() {
        self.fetchController = TransactionFetchController.all
        includeRecurringCancellable = UserDefaults.standard.publisher(for: \.integrate_recurring_expenses_in_month_overview).sink { value in
            self.includeRecurringExpenses = value
        }
        
        let recurringTransactionPublisher = RecurringTransactionStorage.shared.items.eraseToAnyPublisher()
        recurringTransactionCancellable = recurringTransactionPublisher.sink { items in
            self.recurringExpenses = items
        }
        
        let transactionPublisher = fetchController.items.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { items in
            self.transactions = items
            print("Updating \(String(describing: self))")
        }
    }
    
    /// If this initializer is used, {wrappedTransactions} will contain only the transactions in the specified month
    init(date: Date) {
        self.selectedMonthDate = date
        let selectedMonthComps = Calendar.current.dateComponents([.month, .year], from: date)
        self.fetchController = TransactionFetchController(month: selectedMonthComps.month, year: selectedMonthComps.year)
        includeRecurringCancellable = UserDefaults.standard.publisher(for: \.integrate_recurring_expenses_in_month_overview).sink { value in
            self.includeRecurringExpenses = value
        }
        
        let recurringTransactionPublisher = RecurringTransactionStorage.shared.items.eraseToAnyPublisher()
        recurringTransactionCancellable = recurringTransactionPublisher.sink { items in
            self.recurringExpenses = items.filter { $0.isActiveAt(date: date) }
        }
       
        let transactionPublisher = self.fetchController.items.eraseToAnyPublisher()
        transactionCancellable = transactionPublisher.sink { items in
            self.transactions = items.filter({
                let comps = Calendar.current.dateComponents([.month, .year], from: $0.date ?? date)
                return comps.year == selectedMonthComps.year && comps.month == selectedMonthComps.month
            })
        }
    }
    
    private func update() {
        if (self.wrappedTransactions.isEmpty) {
            self.wrappedTransactions = transactions.map { AbstractTransaction(date: $0.date, category: $0.category, amount: $0.amount, isExpense: $0.isExpense)}
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            var abstractTransactions = self.transactions.map { AbstractTransaction(date: $0.date, category: $0.category, amount: $0.amount, isExpense: $0.isExpense)}
            if (self.includeRecurringExpenses) {
                var recurringAbExpenses: [AbstractTransaction]
                if let selectedMonthDate = self.selectedMonthDate {
                    recurringAbExpenses = self.recurringExpenses.map {
                        AbstractTransaction(date: selectedMonthDate.startOfThisMonth, category: $0.category, amount: $0.normalizedMonthlyAmount, isExpense: true)
                    }
                } else {
                    var allRec: [AbstractTransaction] = []
                    for item in self.recurringExpenses {
                        allRec.append(contentsOf: item.individualTransactions)
                    }
                    recurringAbExpenses = allRec
                }
                abstractTransactions.append(contentsOf: recurringAbExpenses)
            }
            DispatchQueue.main.async {
                self.wrappedTransactions = abstractTransactions
            }
        }
        
        
    }
}
