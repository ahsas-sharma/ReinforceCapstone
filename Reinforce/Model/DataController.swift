//
//  DataController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 21/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import CoreData

class DataController {
    let persistantContainer: NSPersistentContainer
    var viewContext : NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    var backgroundContext : NSManagedObjectContext!
    var unsplashContext : NSManagedObjectContext!

    init(modelName : String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }

    func configureContexts() {
        backgroundContext = persistantContainer.newBackgroundContext()
        unsplashContext = persistantContainer.newBackgroundContext()

        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func load (completion: (()-> Void)? = nil) {
        persistantContainer.loadPersistentStores(completionHandler: {
            storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        })

    }

    // Unsplash
    func deleteAllPhotos() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try unsplashContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                unsplashContext.delete(managedObjectData)
            }
            print("Deleted all photos")
        } catch let error as NSError {
            print("Error while deleting data:\(error)")
        }
    }

    func saveUnsplashContext() {
        do {
            try self.unsplashContext.save()
        } catch {
            fatalError("Error while trying to save unsplash context")
        }
    }
}
