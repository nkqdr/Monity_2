//
//  ItemListViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 25.10.22.
//

import Foundation
import Combine

class ItemListViewModel<ListItem>: ObservableObject {
    @Published var items: [ListItem] = []
    @Published var currentItem: ListItem? = nil
    
    private var itemCancellable: AnyCancellable?
    
    init(itemPublisher: AnyPublisher<[ListItem], Never>) {
        itemCancellable = itemPublisher.sink { items in
            self.items = items
        }
    }
    
    // MARK: - Intents
    func deleteItem(_ item: ListItem) {
        fatalError("Delete method has not been implemented. Cannot delete \(item)")
    }
}
