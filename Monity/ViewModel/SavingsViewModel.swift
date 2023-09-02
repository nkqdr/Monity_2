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
            setPercentageChangeLastYear()
            generateLineChartDataPoints()
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
        let netWorthOneYearAgo = vDSP.sum(allCategories.map { $0.lastEntryBefore(oneYearAgo)?.amount ?? 0 })
        if netWorthOneYearAgo != 0 {
            percentChangeInLastYear = (currentNetWorth - netWorthOneYearAgo) / netWorthOneYearAgo
        } else {
            percentChangeInLastYear = 0
        }
    }
    
    private func generateLineChartDataPoints() {
        var dataPoints: [ValueTimeDataPoint] = []
        let uniqueDates: Set<Date> = Set(savingsInLastYear.map { $0.wrappedDate.removeTimeStamp! })
        for uniqueDate in uniqueDates {
            let netWorthAtUniqueDate: Double = vDSP.sum(allCategories.map { $0.lastEntryBefore(uniqueDate) }.map { $0?.amount ?? 0 })
            dataPoints.append(ValueTimeDataPoint(date: uniqueDate, value: netWorthAtUniqueDate))
        }
        self.dataPoints = dataPoints.sorted {
            $0.date < $1.date
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
    static let shared = SavingsViewModel()
    static func forCategory(_ category: SavingsCategory) -> SavingsViewModel {
        return SavingsViewModel(category: category)
    }
    
    private init() {
        let publisher = SavingsFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    private init(category: SavingsCategory) {
        let publisher = SavingsFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
        itemCancellable = publisher.sink { entries in
            self.items = entries.filter { $0.category == category}
        }
    }
    
    // MARK: - Intent
    
    override func deleteItem(_ item: SavingsEntry) {
        SavingStorage.main.delete(item)
    }
}
