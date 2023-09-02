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
    }
    
    static let possibleTimeframeLowerBounds: [TimeframeOptionConfig] = [
        TimeframeOptionConfig(
            label: "picker.lastmonth",
            tagValue: Calendar.current.date(byAdding: DateComponents(month: -1), to: Date())!
        ),
        TimeframeOptionConfig(
            label: "picker.sixmonths",
            tagValue: Calendar.current.date(byAdding: DateComponents(month: -6), to: Date())!
        ),
        TimeframeOptionConfig(
            label: "picker.lastyear",
            tagValue: Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
        ),
        TimeframeOptionConfig(
            label: "picker.fiveyears",
            tagValue: Calendar.current.date(byAdding: DateComponents(year: -5), to: Date())!
        ),
        TimeframeOptionConfig(
            label: "picker.max",
            tagValue: Date.distantPast
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
            self.currentNetWorth = categories.map { $0.lastEntryBefore(Date()) }.map { $0?.amount ?? 0 }.reduce(0, +)
        }
        
        self.savingsCancellable = publisher.sink { values in
            self.allSavingsEntries = values
            self.updateDataPoints(with: values.filter { $0.wrappedDate >= self.selectedTimeframe })
        }
    }
    
    private func updateDataPoints(with savingsEntries: [SavingsEntry]) {
        var dataPoints: [ValueTimeDataPoint] = []
        let uniqueDates: Set<Date> = Set(savingsEntries.map { $0.wrappedDate.removeTimeStamp! })
        
        for uniqueDate in uniqueDates {
            let netWorthAtUniqueDate: Double = vDSP.sum(allSavingsCategories.map { $0.lastEntryBefore(uniqueDate) }.map { $0?.amount ?? 0 }) 
            if let existingDataPoint = lineChartDataPoints.first(where: { $0.date == uniqueDate && $0.value == netWorthAtUniqueDate}) {
                dataPoints.append(existingDataPoint)
                continue
            }
            dataPoints.append(ValueTimeDataPoint(date: uniqueDate, value: netWorthAtUniqueDate))
        }
        
        self.lineChartDataPoints = dataPoints.sorted {
            $0.date < $1.date
        }
    }
    
}

