//
//  MonthlyOverviewViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 11.10.22.
//

import Foundation
import Combine

class MonthlyOverviewViewModel: ObservableObject {
    @Published var remainingDays: Int = 0
    @Published var predictedTotalSpendings: Double = 0
    @Published var spendingsPerDay: Double = 0 {
        didSet {
            let daysInMonth: Int = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 0
            predictedTotalSpendings = spendingsPerDay * Double(daysInMonth)
        }
    }
    @Published var spentThisMonth: Double = 0 {
        didSet {
            let currentDay: Int = Calendar.current.dateComponents([.day], from: Date()).day ?? 1
            spendingsPerDay = spentThisMonth / Double(currentDay)
        }
    }
    @Published var selectedDate: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
    
    private let currentComps: DateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
    private var transactions: [AbstractTransaction] = [] {
        didSet {
            spentThisMonth = transactions.filter { $0.isExpense }.map { $0.amount }.reduce(0, +)
        }
    }
    
    var currentMonthSelected: Bool {
        selectedDate.toDate.isSameMonthAs(Date())
    }
    private var transactionCancellable: AnyCancellable?
    private var startOfNextMonth: Date {
        let correctYear: Int = currentComps.month == 12 ? (currentComps.year ?? 0) + 1 : currentComps.year ?? 1
        let correctMonth: Int = currentComps.month == 12 ? 1 : (currentComps.month ?? 0) + 1
        return Calendar.current.date(from: DateComponents(year: correctYear, month: correctMonth, day: 1)) ?? Date()
    }
    
    public init() {
        let publisher = AbstractTransactionWrapper(date: Date()).$wrappedTransactions.eraseToAnyPublisher()
        transactionCancellable = publisher.sink { items in
            self.transactions = items
        }
        remainingDays = (Calendar.current.dateComponents([.day], from: Date(), to: startOfNextMonth).day ?? 0) + 1
    }
}
