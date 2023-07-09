//
//  CoreDataModelStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 25.10.22.
//

import Foundation
import Combine
import CoreData

class CoreDataModelStorage<ModelClass>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate where ModelClass: NSManagedObject {
    var items = CurrentValueSubject<[ModelClass], Never>([])
    private let itemFetchController: RichFetchedResultsController<ModelClass>
    private let managedObjectContext: NSManagedObjectContext
    
    init(
        sortDescriptors: [NSSortDescriptor],
        keyPathsForRefreshing: Set<String> = [],
        predicate: NSPredicate? = nil,
        managedObjectContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        let request = RichFetchRequest<ModelClass>(entityName: ModelClass.entity().name ?? "")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        request.relationshipKeyPathsForRefreshing = keyPathsForRefreshing
        self.itemFetchController = RichFetchedResultsController<ModelClass>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.managedObjectContext = managedObjectContext
        super.init()
        itemFetchController.delegate = self
        do {
            try itemFetchController.performFetch()
            items.value = itemFetchController.fetchedObjects! as? [ModelClass] ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ModelClass.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        self.managedObjectContext.performAndWait {
            do {
                try self.managedObjectContext.executeAndMergeChanges(using: deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [ModelClass] else { return }
        self.items.value = items
        print("Refreshing \(String(describing: self)) with \(items.count) items.")
    }
}
