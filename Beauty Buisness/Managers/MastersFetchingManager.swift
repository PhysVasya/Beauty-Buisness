//
//  MastersFetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import CoreData


class MastersFetchingManager {
    
    static let shared = MastersFetchingManager()
    
    public let managedObjectContext = CoreDataStack.shared.context
    
    private init () {}

    
    public func fetchMasters (_ delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<Master>? {
        
        let request: NSFetchRequest<Master> = Master.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Master.name), ascending: true)
        request.sortDescriptors = [sort]
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = delegate
            do {
                try resultsController.performFetch()
                return resultsController
            } catch let error as NSError {
                print(FetchingErrors.errorFetchingMasters(error))
                return nil
            }
        
        
    }
    
    public func fetchExistingMaster (masterName: String?) async -> [Master]? {
        
        guard let masterName = masterName else {
            return nil
        }
        
        let request: NSFetchRequest<Master> = Master.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS [cd] %@", masterName)
        
        return await withCheckedContinuation { continuation in
            do {
                let result = try managedObjectContext.fetch(request)
                continuation.resume(returning: result)
            } catch let error as NSError {
                print(FetchingErrors.errorFetchingExistingMaster(error))
                continuation.resume(returning: nil)
            }
        }
        
    }
    
    public func saveNewMaster (_ masterName: String, _ masterPhone: String) {
        
        let newMaster = Master(context: managedObjectContext)
        newMaster.name = masterName
        newMaster.phone = masterPhone
        
        CoreDataStack.shared.saveContext()
        
    }
    
    //Batch Delete
    
    public func deleteMaster (_ master: Master) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = Master.fetchRequest()
        request.predicate = NSPredicate(format: "SELF == %@", master)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        request.resultType = .managedObjectIDResultType
        
        do {
            let batchDelete = try managedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else  { return }
         
            let results: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: results, into: [managedObjectContext])
            
        } catch let error as NSError {
            print("Error deleting master \(error)")
        }
    }
    
}
