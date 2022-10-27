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
    @Published var savingEntries: [SavingsEntry] = [] {
        didSet {
            currentNetWorth = items.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
            uniqueDates = Set(savingEntries.map { $0.wrappedDate.removeTimeStamp ?? Date() })
            generateLineChartDataPoints()
        }
    }
    @Published var timeFrameToDisplay: Int = 1
    @Published var percentChangeInLastYear: Double = 0.35
    @Published var lineChartData: [ValueTimeDataPoint] = [] {
        didSet {
            print(lineChartData.map { $0.date })
        }
    }
    @Published var currentNetWorth: Double = 0
    @Published var uniqueDates: Set<Date> = []
    
    var minLineChartValue: Double {
        lineChartData.map { $0.value }.min() ?? 0
    }
    
    var maxLineChartValue: Double {
        lineChartData.map { $0.value }.max() ?? 0
    }
    
    private var entryCancellable: AnyCancellable?
    
    private init() {
        let categoryPublisher = SavingsCategoryStorage.shared.items.eraseToAnyPublisher()
        let entryPublisher = SavingStorage.shared.items.eraseToAnyPublisher()
        lineChartData = [
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 0), value: 1562.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 86000), value: 2062.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 170000), value: 1962.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 250000), value: 2510.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 320000), value: 2862.02),
        ]
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
        lineChartData = dataPoints.sorted {
            $0.date < $1.date
        }
    }
    
    func getTotalSumFor(_ label: SavingsCategoryLabel) -> Double {
        return items.filter { $0.label == label.rawValue }.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
    }
    
    func getFractionPercentageFor(_ label: SavingsCategoryLabel) -> Double {
        if currentNetWorth != 0 {
            return getTotalSumFor(label) / currentNetWorth
        }
        return 0
    }
}
