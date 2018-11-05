//
//  CoreDataManager.swift
//  Places
//
//  Created by Алексей Воронов on 03/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Creating an array containing storage data
var places: [Place] {
    
    let request = NSFetchRequest<Place>(entityName: "Place")
    
    let sd = NSSortDescriptor(key: "date", ascending: false)
    request.sortDescriptors = [sd]
    
    let array = try? CoreDataManager.sharedInstance.managedObjectContext.fetch(request)
    
    if array != nil {
        return array!
    }
    
    return []
}

//MARK: - Working with local storage
class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Places")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
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
