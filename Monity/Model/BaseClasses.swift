//
//  BaseFetchController.swift
//  Monity
//
//  Created by Niklas Kuder on 25.10.22.
//

import Foundation
import Combine
import CoreData

class BaseFetchController<ModelClass>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate where ModelClass: NSManagedObject {
    var items = CurrentValueSubject<[ModelClass], Never>([])
    let itemFetchController: RichFetchedResultsController<ModelClass>
    private let managedObjectContext: NSManagedObjectContext
    
    init(
        sortDescriptors: [NSSortDescriptor],
        keyPathsForRefreshing: Set<String> = [],
        predicate: NSPredicate? = nil,
        managedObjectContext: NSManagedObjectContext = PersistenceController.shared.managedObjectContext
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
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [ModelClass] else { return }
        self.items.value = items
        print("Refreshing \(String(describing: self)) with \(items.count) items.")
    }
}

class CoreDataStorage {
    let context: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.context = managedObjectContext
    }
    
    func add(set rows: any Sequence<String>) -> Bool {
        fatalError("add(set:) has not been implemented")
    }
}

class ResettableStorage<T>: CoreDataStorage where T: NSManagedObject {
    func delete(_ obj: T) {
        self.context.performAndWait {
            self.context.delete(obj)
            do {
                try self.context.save()
            } catch {
                self.context.rollback()
                print("Failed to save context \(error.localizedDescription)")
            }
        }
    }
    
    func delete(allIn objs: [T]) {
        self.context.performAndWait {
            for obj in objs {
                self.context.delete(obj)
            }
            do {
                try self.context.save()
            } catch {
                self.context.rollback()
                print("Failed to save context \(error.localizedDescription)")
            }
        }
    }
    
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        self.context.performAndWait {
            do {
                try self.context.executeAndMergeChanges(using: deleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}
