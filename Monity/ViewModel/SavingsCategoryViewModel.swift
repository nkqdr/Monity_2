//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine

class SavingsCategoryViewModel: ItemListViewModel<SavingsCategory> {
    static let shared = SavingsCategoryViewModel()
    @Published var shownCategories: [SavingsCategory] = []
    @Published var hiddenCategories: [SavingsCategory] = []
    @Published var yearlySavingsRate: Double = 0
    @Published var savingEntries: [SavingsEntry] = [] {
        didSet {
            currentNetWorth = items.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
            uniqueDates = Set(savingEntries.map { $0.wrappedDate.removeTimeStamp ?? Date() })
            generateLineChartDataPoints()
            generateFilteredLineChartDataPoints()
            yearlySavingsRate = calculateYearlySavingsRate()
        }
    }
    @Published var timeFrameToDisplay: Int = 31536000 {
        didSet {
            generateFilteredLineChartDataPoints()
            yearlySavingsRate = calculateYearlySavingsRate()
        }
    }
    @Published var percentChangeInLastYear: Double = 0
    @Published var allLineChartData: [ValueTimeDataPoint] = [] {
        didSet {
            setPercentageChangeLastYear()
        }
    }
    @Published var lastYearLineChartData: [ValueTimeDataPoint] = []
    @Published var filteredLineChartData: [ValueTimeDataPoint] = []
    @Published var currentNetWorth: Double = 0
    @Published var uniqueDates: Set<Date> = []
    
    private var entryCancellable: AnyCancellable?
    
    public init() {
        let categoryPublisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        let entryPublisher = SavingsFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: categoryPublisher)
        entryCancellable = entryPublisher.sink { entries in
            self.savingEntries = entries
        }
    }
    
    private func calculateYearlySavingsRate() -> Double {
        let sortedEntries = filteredLineChartData.sorted {
            $0.date < $1.date
        }
        guard let firstEntry = sortedEntries.first, let lastEntry = sortedEntries.last, sortedEntries.count > 1 else {
            return 0
        }
        let amountDiff = abs(firstEntry.value - lastEntry.value)
        let dayDiff = Calendar.current.numberOfDaysBetween(firstEntry.date, and: lastEntry.date)
        let amountPerDay = amountDiff / Double(dayDiff)
        return amountPerDay * 365
    }
    
    func generateLineChartDataPoints() {
        var dataPoints: [ValueTimeDataPoint] = []
        for uniqueDate in uniqueDates {
            let netWorthAtUniqueDate: Double = items.map { $0.lastEntryBefore(uniqueDate) }.map { $0?.amount ?? 0 }.reduce(0, +)
            dataPoints.append(ValueTimeDataPoint(date: uniqueDate, value: netWorthAtUniqueDate))
        }
        allLineChartData = dataPoints.sorted {
            $0.date < $1.date
        }
    }
    
    override func onItemsSet() {
        shownCategories = items.filter { !$0.isHidden }
        hiddenCategories = items.filter { $0.isHidden }
    }
    
    var lowerBoundDate: Date {
        timeFrameToDisplay > 0 ? Date(timeIntervalSinceNow: -Double(timeFrameToDisplay)).removeTimeStamp ?? Date() : Date.distantPast
    }
    
    func generateFilteredLineChartDataPoints() {
        filteredLineChartData = allLineChartData.filter { $0.date.removeTimeStamp ?? Date() >= lowerBoundDate }
    }
    
    func setPercentageChangeLastYear() {
        let latest: Double = allLineChartData.last?.value ?? 0
        let oneYearAgo: Date = Date(timeIntervalSinceNow: -31536000) // One Year has 31536000 seconds
        let entriesBeforeOneYearAgo = allLineChartData.filter { $0.date.removeTimeStamp ?? Date() <= oneYearAgo.removeTimeStamp ?? Date() }
        let valueOneYearAgo: Double = entriesBeforeOneYearAgo.count > 0 ? entriesBeforeOneYearAgo.last?.value ?? 0 : allLineChartData.first?.value ?? 0
        let increase = latest - valueOneYearAgo
        if valueOneYearAgo != 0 {
            percentChangeInLastYear = increase / valueOneYearAgo
        } else {
            percentChangeInLastYear = 0
        }
    }
    
    
    // MARK: - Intents
    
    func getXYearProjection(_ years: Int) -> Double {
        return currentNetWorth + Double(years) * yearlySavingsRate
    }
    
    func toggleHiddenFor(_ category: SavingsCategory) {
        let _ = SavingsCategoryStorage.main.update(category, isHidden: !category.isHidden)
    }
}
