//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine
import Accelerate

class SavingsCategoryGridVM: ObservableObject {
    @Published var categories: [SavingsCategory] = []
    
    private var categoryCancellable: AnyCancellable?
    private var fetchController: SavingsCategoryFetchController
    
    init(isHidden: Bool) {
        self.fetchController = SavingsCategoryFetchController(isHidden: isHidden)
        let publisher = self.fetchController.items.eraseToAnyPublisher()
        
        self.categoryCancellable = publisher.sink { categories in
            self.categories = categories.sorted(by: { c1, c2 in
                (c1.lastEntry?.amount ?? 0) > (c2.lastEntry?.amount ?? 0)
            })
        }
    }
}

class SavingsCategoryViewModel: ItemListViewModel<SavingsCategory> {
    static let shared = SavingsCategoryViewModel()
    @Published var shownCategories: [SavingsCategory] = []
    @Published var hiddenCategories: [SavingsCategory] = []
    @Published var currentNetWorth: Double = 0
    
    private var entryCancellable: AnyCancellable?
    
    public init() {
        let categoryPublisher = SavingsCategoryFetchController.all.items.eraseToAnyPublisher()
        super.init(itemPublisher: categoryPublisher)
    }
    
    override func onItemsSet() {
        shownCategories = items.filter { !$0.isHidden }
        hiddenCategories = items.filter { $0.isHidden }
        self.currentNetWorth = vDSP.sum(self.items.map(\.lastEntry).map { $0?.amount ?? 0 })
    }
}
