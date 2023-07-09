//
//  RecurringTransactionsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 28.02.23.
//

import Foundation

class RecurringTransactionsViewModel: ItemListViewModel<RecurringTransaction> {
    public static let shared = RecurringTransactionsViewModel()
    @Published var activeTransactions: [RecurringTransaction] = []
    @Published var archivedTransactions: [RecurringTransaction] = []
    @Published var chartDataPoints: [ValueTimeDataPoint] = []
    @Published var currentMonthlyPayment: Double = 0
    
    private init() {
        let publisher = RecurringTransactionFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    override func onItemsSet() {
        activeTransactions = items.filter({ $0.endDate == nil }).sorted { v1, v2 in
            v1.normalizedMonthlyAmount > v2.normalizedMonthlyAmount
        }
        archivedTransactions = items.filter({ $0.endDate != nil }).sorted { v1, v2 in
            v1.normalizedMonthlyAmount > v2.normalizedMonthlyAmount
        }
        chartDataPoints = buildChartDataPoints()
        currentMonthlyPayment = chartDataPoints.last?.value ?? 0
    }
    
    private func buildChartDataPoints() -> [ValueTimeDataPoint] {
        var dataPoints: [ValueTimeDataPoint] = []
        var borderDates: Set<Date> = Set()
        if !items.isEmpty {
            borderDates.update(with: Date().removeTimeStamp!)
        }
        for item in items {
            if let startDate = item.startDate {
                borderDates.update(with: startDate)
            }
            if let endDate = item.endDate {
                borderDates.update(with: endDate)
            }
        }
        for date in borderDates {
            let dp = ValueTimeDataPoint(
                date: date,
                value: items.filter({
                    $0.isActiveAt(date: date)
                }).map({ $0.normalizedMonthlyAmount }).reduce(0, +)
            )
            dataPoints.append(dp)
        }
        return dataPoints.sorted { d1, d2 in
            return d1.date < d2.date
        }
    }
    
    // MARK: - Intent
    
    override func deleteItem(_ item: RecurringTransaction) {
        RecurringTransactionStorage.main.delete(item)
    }
}
