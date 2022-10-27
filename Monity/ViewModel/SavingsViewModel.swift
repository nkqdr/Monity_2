//
//  SavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 27.10.22.
//

import Foundation
import Combine

class SavingsViewModel: ItemListViewModel<SavingsEntry> {
    static let shared = SavingsViewModel()
    static func forCategory(_ category: SavingsCategory) -> SavingsViewModel {
        return SavingsViewModel(category: category)
    }
    
    private init() {
        let publisher = SavingStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
    }
    
    private init(category: SavingsCategory) {
        let publisher = SavingStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: publisher)
        itemCancellable = publisher.sink { entries in
            self.items = entries.filter { $0.category == category}
        }
    }
    
    // MARK: - Intent
    
    override func deleteItem(_ item: SavingsEntry) {
        SavingStorage.shared.delete(item)
    }
}
