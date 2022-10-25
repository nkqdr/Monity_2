//
//  SavingsCategoryStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 24.10.22.
//

import Foundation
import Combine
import CoreData

class SavingsCategoryStorage: NSObject, ObservableObject {
    var categories = CurrentValueSubject<[SavingsCategory], Never>([])
    private let categoryFetchController: NSFetchedResultsController<SavingsCategory>
    
    static let shared: SavingsCategoryStorage = SavingsCategoryStorage()
    
    private override init() {
        let request = SavingsCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavingsCategory.name, ascending: true)]
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
    
    func add(name: String, label: SavingsCategoryLabel) -> SavingsCategory {
        let category = SavingsCategory(context: PersistenceController.shared.container.viewContext)
        category.id = UUID()
        category.name = name
        category.label = label.rawValue
        category.entries = []
        try? PersistenceController.shared.container.viewContext.save()
        return category
    }
    
    func update(_ category: SavingsCategory, name: String?, label: SavingsCategoryLabel) -> Bool {
        PersistenceController.shared.container.viewContext.performAndWait {
            category.name = name ?? category.name
            category.label = label.rawValue
            if let _ = try? PersistenceController.shared.container.viewContext.save() {
                return true
            } else {
                return false
            }
        }
    }
    
    func delete(_ category: SavingsCategory) {
        PersistenceController.shared.container.viewContext.delete(category)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            PersistenceController.shared.container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
//    func delete(allIn categories: [TransactionCategory]) {
//        for category in categories {
//            PersistenceController.shared.container.viewContext.delete(category)
//        }
//        do {
//            try PersistenceController.shared.container.viewContext.save()
//        } catch {
//            PersistenceController.shared.container.viewContext.rollback()
//            print("Failed to save context \(error.localizedDescription)")
//        }
//    }
}

extension SavingsCategoryStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let categories = controller.fetchedObjects as? [SavingsCategory] else { return }
        print("Context has changed, reloading categories")
        self.categories.value = categories
    }
}
