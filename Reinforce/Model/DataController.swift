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

    init(modelName : String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }

    func configureContexts() {
        backgroundContext = persistantContainer.newBackgroundContext()

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
}
