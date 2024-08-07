//
//  Persistence.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)
    
    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: PersistenceController.self)
        
        guard let url = bundle.url(forResource: "Monity", withExtension: "momd") else {
            fatalError("Failed to locate momd file for Monity")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for Monity")
        }
        
        return model
    }()
    
    static var previewContext: NSManagedObjectContext {
        let controller = PersistenceController(inMemory: true)
        let context = controller.managedObjectContext
        let fetchRequest = TransactionCategory.fetchRequest()
        let fetchResult: [TransactionCategory] = (try? context.fetch(fetchRequest)) ?? []
        
        for res in fetchResult {
            context.performAndWait {
                context.delete(res)
                try? context.save()
            }
        }
        
        context.performAndWait {
            for idx in 0...5 {
                let t = TransactionCategory(context: context)
                t.id = UUID()
                t.name = "Category\(idx+1)"
                if idx % 2 == 0 {
                    t.iconName = "carrot.fill"
                }
            }
            try? context.save()
        }
        return context
    }

    let container: NSPersistentContainer
    
    var managedObjectContext: NSManagedObjectContext {
        self.container.viewContext
    }

    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(
            name: "Monity", managedObjectModel: Self.managedObjectModel
        )
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public func getSqliteStoreSize() -> String {
        guard let storeUrl = self.container.viewContext.persistentStoreCoordinator!.persistentStores.first?.url else {
            print("There is no store url")
            return ""
        }
        return self.getSqliteStoreSize(forPersistentContainerUrl: storeUrl)
    }
    
    public func getSqliteStoreSize(forPersistentContainerUrl storeUrl: URL) -> String {
        do {
            let size = try Data(contentsOf: storeUrl)
            if size.count < 1 {
                print("Size could not be determined.")
                return ""
            }
            let bcf = ByteCountFormatter()
//            bcf.allowedUnits = [.useMB, .useKB, .useBytes] // This restricts possible units
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(size.count))
            return string
        } catch {
            print("Failed to get size of store: \(error)")
            return ""
        }
    }
}
