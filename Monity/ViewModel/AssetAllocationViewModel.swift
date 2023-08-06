//
//  AssetAllocationViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 12.04.23.
//

import Foundation
import Combine

class AssetAllocationViewModel: ObservableObject {
    @Published var entriesExist: Bool = false
    @Published var allLabels: [SavingsCategoryLabel] = SavingsCategoryLabel.allCasesWithoutNone
    
    private var latestSnapshots: [SavingsEntry] = [] {
        didSet {
            self.entriesExist = !latestSnapshots.isEmpty
            self.allLabels = SavingsCategoryLabel.allCasesWithoutNone.filter { getTotalSumFor($0) > 0 }
        }
    }
    private var savingsCancellable: AnyCancellable?
    
    init() {
        let savingsPub = SavingsFetchController.all.items.eraseToAnyPublisher()
        
        self.savingsCancellable = savingsPub.sink { items in
            var latestByCategory: [SavingsCategory: SavingsEntry] = Dictionary()
            for item in items {
                guard let category = item.category else {
                    continue
                }
                guard let currentLatest = latestByCategory[category] else {
                    latestByCategory[category] = item
                    continue
                }
                if currentLatest.wrappedDate < item.wrappedDate {
                    latestByCategory[category] = item
                }
            }
            self.latestSnapshots = Array(latestByCategory.values)
        }
    }
    
    func getAssetAllocationDatapointsFor(_ label: SavingsCategoryLabel) -> [AssetAllocationDataPoint] {
        var dataPoints: [AssetAllocationDataPoint] = []
        let categories = latestSnapshots.filter { $0.amount > 0 && $0.category != nil }.map { $0.category! }.filter { $0.label == label.rawValue }
        let totalSum: Double = categories.map { $0.lastEntry?.amount ?? 0 }.reduce(0, +)
        for category in categories {
            let lastValue: Double = category.lastEntry?.amount ?? 0
            dataPoints.append(
                AssetAllocationDataPoint(category: category, totalAmount: lastValue, relativeAmount: lastValue / totalSum)
            )
        }
        return dataPoints.sorted {
            $0.totalAmount > $1.totalAmount
        }
    }
    
    func getTotalSumFor(_ label: SavingsCategoryLabel) -> Double {
        return latestSnapshots.filter { $0.category?.label == label.rawValue }.map { $0.amount }.reduce(0, +)
    }
}
