//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine

class SavingsViewModel: ItemListViewModel<SavingsCategory> {
    static let shared = SavingsViewModel()
    @Published var timeFrameToDisplay: Int = 0
    @Published var percentChangeInLastYear: Double = 0.35
    @Published var lineChartData: [ValueTimeDataPoint] = [] {
        didSet {
            print(lineChartData)
        }
    }
    
    var minLineChartValue: Double {
        lineChartData.map { $0.value }.min() ?? 0
    }
    
    var maxLineChartValue: Double {
        lineChartData.map { $0.value }.max() ?? 0
    }
    
    private init() {
        let categoryPublisher = SavingsCategoryStorage.shared.items.eraseToAnyPublisher()
        lineChartData = [
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 0), value: 1562.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 86000), value: 2062.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 170000), value: 1962.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 250000), value: 2510.02),
            ValueTimeDataPoint(date: Date(timeIntervalSinceNow: 320000), value: 2862.02),
        ]
        super.init(itemPublisher: categoryPublisher)
    }
    
    override func onItemsSet() {
        // TODO: Set the percentage changed.
    }
}
