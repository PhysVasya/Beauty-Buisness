//
//  CoreDataStack.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 05.04.2022.
//

import Foundation
import CoreData


class CoreDataStack {
    
    static let shared = CoreDataStack(modelName: "Beauty_Buisness")

    private let modelName: String
    
    public init (modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    public lazy var context: NSManagedObjectContext = {
        return container.viewContext
    }()
    
    public func saveContext() {
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving context \(error), \(error.userInfo)")
        }
    }
    
    public func clearDB () {
        
        guard let url = container.persistentStoreDescriptions.first?.url else {
            return
        }
        
        let coordinator = container.persistentStoreCoordinator
        do {
            try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error as NSError {
            print("Error destroying PStore \(error), \(error.userInfo)")
        }
    }
    
}
