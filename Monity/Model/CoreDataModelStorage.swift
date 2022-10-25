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
    private let itemFetchController: NSFetchedResultsController<ModelClass>
    
    init(sortDescriptors: [NSSortDescriptor]) {
        let request = ModelClass.fetchRequest()
        request.sortDescriptors = sortDescriptors
        itemFetchController = NSFetchedResultsController<ModelClass>(
            fetchRequest: request as! NSFetchRequest<ModelClass>,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        itemFetchController.delegate = self
        do {
            try itemFetchController.performFetch()
            items.value = itemFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [ModelClass] else { return }
        self.items.value = items
    }
}
