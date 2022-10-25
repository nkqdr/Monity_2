//
//  SettingsSavingsViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation

class SettingsSavingsViewModel: ItemListViewModel<SavingsCategory> {
    
    init() {
        let itemPublisher = SavingsCategoryStorage.shared.items.eraseToAnyPublisher()
        super.init(itemPublisher: itemPublisher)
    }
    
    // MARK: - Intents
    
    override func deleteItem(_ item: SavingsCategory) {
        SavingsCategoryStorage.shared.delete(item)
    }
}
