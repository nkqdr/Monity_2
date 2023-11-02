//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import Foundation
import Combine
import Accelerate

class SavingsTileViewModel: ObservableObject {
    @Published var dataPoints: [ValueTimeDataPoint] = []
    @Published var allCategories: [SavingsCategory] = []
    @Published var savingsInLastYear: [SavingsEntry] = [] {
        didSet {
            self.dataPoints = LineChartDataBuilder.generateSavingsLineChartData(for: savingsInLastYear)
            setPercentageChangeLastYear()
        }
    }
    @Published var percentChangeInLastYear: Double = 0
    
    private var savingsCancellable: AnyCancellable?
    private var categoryCancellable: AnyCancellable?
    private var savingsFetchController: SavingsFetchController
    
    init() {
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        self.savingsFetchController = SavingsFetchController(since: oneYearAgo)
        let publisher = self.savingsFetchController.items.eraseToAnyPublisher()
        let categoryPublisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        self.categoryCancellable = categoryPublisher.sink { categories in
            self.allCategories = categories
        }
        self.savingsCancellable = publisher.sink { entries in
            self.savingsInLastYear = entries
        }
    }
    
    private func setPercentageChangeLastYear() {
        let currentNetWorth = vDSP.sum(allCategories.map { $0.lastEntry?.amount ?? 0 })
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        var netWorthOneYearAgo = vDSP.sum(allCategories.map { $0.lastEntryBefore(oneYearAgo)?.amount ?? 0 })
        if netWorthOneYearAgo == 0 {
            // No savings entries before one year ago, so just take the first dataPoint as point of reference
            netWorthOneYearAgo = dataPoints.first?.value ?? 0
        }
        if netWorthOneYearAgo != 0 {
            percentChangeInLastYear = (currentNetWorth - netWorthOneYearAgo) / netWorthOneYearAgo
        } else {
            percentChangeInLastYear = 0
        }
    }
}

class SavingsPredictionViewModel: ObservableObject {
    @Published var allCategories: [SavingsCategory] = [] {
        didSet {
            self.currentNetWorth = allCategories.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
            self.yearlySavingsRate = calculateChangeInLastYear()
        }
    }
    @Published var yearlySavingsRate: Double = 0
    @Published var currentNetWorth: Double = 0
    
    private var categoryCancellable: AnyCancellable?
    
    init() {
        let publisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        self.categoryCancellable = publisher.sink { val in
            self.allCategories = val
        }
    }
    
    private func calculateChangeInLastYear() -> Double {
        let oneYearAgo = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())
        let allEntriesOneYearAgo = allCategories.map {
            $0.lastEntryBefore(oneYearAgo ?? Date())?.amount ?? 0
        }
        let netWorthOneYearAgo = vDSP.sum(allEntriesOneYearAgo)
        return currentNetWorth - netWorthOneYearAgo
    }
    
    func getXYearProjection(_ years: Int) -> Double {
        return currentNetWorth + Double(years) * yearlySavingsRate
    }
}

class SavingsCategoryPickerViewModel: ObservableObject {
    @Published var allCategories: [SavingsCategory] = []
    private var categoryCancellable: AnyCancellable?
    
    init() {
        let publisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        self.categoryCancellable = publisher.sink { val in
            self.allCategories = val
        }
    }
}

class SavingsViewModel: ItemListViewModel<SavingsEntry> {
    struct EntryGroup: Identifiable {
        var id = UUID()
        var date: Date
        var entries: [SavingsEntry]
        
        mutating func setEntries(_ entries: [SavingsEntry]) {
            self.entries = entries
        }
    }
    
    static let shared = SavingsViewModel()
    static func forCategory(_ category: SavingsCategory) -> SavingsViewModel {
        return SavingsViewModel(category: category)
    }
    @Published var groupedItems: [EntryGroup] = []
    @Published var lineChartDataPoints: [ValueTimeDataPoint] = []
    
    var lastEntryBeforeLastYear: ValueTimeDataPoint? {
        let dps = self.category?.lineChartDataPoints(after: Date.distantPast) ?? []
        let entriesBeforeThisYear = dps.filter { $0.date < Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!}
        if entriesBeforeThisYear.isEmpty {
            return dps.first
        }
        return entriesBeforeThisYear.last
    }
    
    private var category: SavingsCategory?
    private var fetchController: SavingsFetchController
    
    private init() {
        self.fetchController = SavingsFetchController.all
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    private init(category: SavingsCategory) {
        self.fetchController = SavingsFetchController(category: category)
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        self.category = category
        super.init(itemPublisher: publisher)
    }
    
    private func calcGroupedItems() -> [EntryGroup] {
        var groups: [EntryGroup] = []
        let uniqueYears: [Date] = Dictionary(grouping: self.items) { item in
            let comps = Calendar.current.dateComponents([.year], from: item.wrappedDate)
            return Calendar.current.date(from: comps)!
        }.keys.sorted {
            $0 > $1
        }
        
        for year in uniqueYears {
            let itemsInGroup = self.items.filter { Calendar.current.isDate($0.wrappedDate, equalTo: year, toGranularity: .year)}
            var group = self.groupedItems.first(where: { Calendar.current.isDate($0.date, equalTo: year, toGranularity: .year)})
            
            if group != nil  {
                group!.setEntries(itemsInGroup)
            } else {
                group = EntryGroup(date: year, entries: itemsInGroup)
            }
            groups.append(group!)
        }
        
        return groups.sorted {
            $0.date > $1.date
        }
    }
    
    override func onItemsSet() {
        self.groupedItems = self.calcGroupedItems()
        self.lineChartDataPoints = LineChartDataBuilder.generateSavingsLineChartData(for: self.items)
    }
    
    // MARK: - Intent
    
    override func deleteItem(_ item: SavingsEntry) {
        SavingStorage.main.delete(item)
    }
}
