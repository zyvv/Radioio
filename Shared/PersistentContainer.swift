//
//  PersistentContainer.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/20.
//

import CoreData

class PersistentContainer {
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {}

    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Radioio")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
