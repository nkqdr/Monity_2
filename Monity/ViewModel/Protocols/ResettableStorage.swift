//
//  ResettableStorage.swift
//  Monity
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import CoreData

class CoreDataStorage {
    let context: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.context = managedObjectContext
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
