//
//  CustomersFetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import CoreData


class CustomersFetchingManager  {
    
    static let shared = CustomersFetchingManager()
    
    public let managedObjectContext = CoreDataStack.shared.context
    
    private init () {}
    
    public func fetchCustomers (delegate: NSFetchedResultsControllerDelegate?)  -> NSFetchedResultsController<Customer>? {
        
        let request: NSFetchRequest<Customer> = Customer.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Customer.name), ascending: true)
        request.sortDescriptors = [sort]
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: #keyPath(Customer.name), cacheName: nil)
        resultsController.delegate = delegate
            do {
                try resultsController.performFetch()
                return resultsController
            } catch let error as NSError {
                print(FetchingErrors.errorFetchingCustomers(error))
                return nil
            }
        
    }
    
    public func fetchExistingCustomer (customerName: String?) async -> [Customer]? {
        
        guard let customerName = customerName else {
            return nil
        }
        
        let request: NSFetchRequest<Customer> = Customer.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS [cd] %@", customerName)
        
        return await withCheckedContinuation { continuation in
            do {
                let result = try managedObjectContext.fetch(request)
                continuation.resume(returning: result)
            } catch let error as NSError {
                print(FetchingErrors.errorFetchingExistingCustomer(error))
                continuation.resume(returning: nil)
            }
        }
        
    }
    
    public func saveNewCustomer (_ name: String, _ phoneNumber: String) {
        
        let newCustomer = Customer(context: managedObjectContext)
        newCustomer.name = name
        newCustomer.phone = phoneNumber
        
        CoreDataStack.shared.saveContext()
        
    }
    
    public func deleteCustomer (_ customer: Customer) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = Customer.fetchRequest()
        request.predicate = NSPredicate(format: "SELF == %@", customer)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let batchDelete = try managedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            
            let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [managedObjectContext])

        } catch let error as NSError {
            print("Error deleting customer \(error)")
        }
        
    }
    
}
