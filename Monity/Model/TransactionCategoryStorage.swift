//
//  TransactionCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation
import Combine
import CoreData

class TransactionCategoryStorage: NSObject, ObservableObject {
    var categories = CurrentValueSubject<[TransactionCategory], Never>([])
    private let categoryFetchController: NSFetchedResultsController<TransactionCategory>
    
    static let shared: TransactionCategoryStorage = TransactionCategoryStorage()
    
    private override init() {
        let request = TransactionCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionCategory.name, ascending: true)]
        categoryFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        categoryFetchController.delegate = self
        do {
            try categoryFetchController.performFetch()
            categories.value = categoryFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func add(name: String) -> TransactionCategory {
        let category = TransactionCategory(context: PersistenceController.shared.container.viewContext)
        category.name = name
        category.id = UUID()
        try? PersistenceController.shared.container.viewContext.save()
        return category
    }
    
//    func delete(_ task: Task) {
//        PersistenceController.shared.persistentContainer.viewContext.delete(task)
//        do {
//            try PersistenceController.shared.persistentContainer.viewContext.save()
//        } catch {
//            PersistenceController.shared.persistentContainer.viewContext.rollback()
//            print("Failed to save context \(error.localizedDescription)")
//        }
//    }
}

extension TransactionCategoryStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let categories = controller.fetchedObjects as? [TransactionCategory] else { return }
        print("Context has changed, reloading tasks")
        self.categories.value = categories
    }
}

