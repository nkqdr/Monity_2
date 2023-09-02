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
    @Published var savingEntries: [SavingsEntry] = [] {
        didSet {
            print("Did set")
            currentNetWorth = items.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
            uniqueDates = Set(savingEntries.map { $0.wrappedDate.removeTimeStamp ?? Date() })
            generateLineChartDataPoints()
            generateFilteredLineChartDataPoints()
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
        Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
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
}
