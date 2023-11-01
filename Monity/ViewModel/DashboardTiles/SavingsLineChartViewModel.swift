//
//  SavingsLineChartViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 06.08.23.
//

import Foundation
import Combine
import Accelerate


class SavingsLineChartViewModel: ObservableObject {
    struct TimeframeOptionConfig: Identifiable, Hashable {
        var id = UUID()
        var label: String
        var tagValue: Date
        var granularity: Calendar.Component
    }
    
    static let possibleTimeframeLowerBounds: [TimeframeOptionConfig] = [
        TimeframeOptionConfig(
            label: "picker.lastmonth",
            tagValue: Calendar.current.date(byAdding: DateComponents(month: -1), to: Date())!,
            granularity: .second
        ),
        TimeframeOptionConfig(
            label: "picker.sixmonths",
            tagValue: Calendar.current.date(byAdding: DateComponents(month: -6), to: Date())!,
            granularity: .second
        ),
        TimeframeOptionConfig(
            label: "picker.lastyear",
            tagValue: Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!,
            granularity: .day
        ),
        TimeframeOptionConfig(
            label: "picker.fiveyears",
            tagValue: Calendar.current.date(byAdding: DateComponents(year: -5), to: Date())!,
            granularity: .weekOfYear
        ),
        TimeframeOptionConfig(
            label: "picker.max",
            tagValue: Date.distantPast,
            granularity: .month
        )
    ]
    
    @Published var selectedTimeframe: Date = possibleTimeframeLowerBounds[2].tagValue {
        didSet {
            self.updateDataPoints(with: allSavingsEntries.filter { $0.wrappedDate >= self.selectedTimeframe })
        }
    }
    @Published var lineChartDataPoints: [ValueTimeDataPoint] = []
    @Published var allSavingsEntries: [SavingsEntry] = []
    @Published var allSavingsCategories: [SavingsCategory] = []
    @Published var currentNetWorth: Double = 0
    
    private var savingsCancellable: AnyCancellable?
    private var savingsCategoryCancellable: AnyCancellable?
    
    init() {
        let publisher = SavingsFetchController.all.items.eraseToAnyPublisher()
        let categoryPublisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        
        self.savingsCategoryCancellable = categoryPublisher.sink { categories in
            self.allSavingsCategories = categories
            self.currentNetWorth = vDSP.sum(categories.map(\.lastEntry).map { $0?.amount ?? 0 })
        }
        
        self.savingsCancellable = publisher.sink { values in
            print("LineChartVM")
            self.allSavingsEntries = values
            self.updateDataPoints(with: values.filter { $0.wrappedDate >= self.selectedTimeframe })
        }
    }
    
    private func updateDataPoints(with savingsEntries: [SavingsEntry]) {
        let granularity = SavingsLineChartViewModel.possibleTimeframeLowerBounds.first(where:  {
            $0.tagValue == self.selectedTimeframe
        })?.granularity ?? .second
        self.lineChartDataPoints = LineChartDataBuilder.generateSavingsLineChartData(for: savingsEntries, granularity: granularity)
    }
    
}

