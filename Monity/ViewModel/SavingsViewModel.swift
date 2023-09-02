//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import Foundation
import Combine
import Accelerate

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
