//
//  FetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 05.04.2022.
//

import Foundation
import CoreData


class EventsFetchingManager {

    static let shared = EventsFetchingManager()
    public let managedObjectContext = CoreDataStack.shared.context
    
    private init () {}
    
    public func fetchEventsForToday (_ day: Day, delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Event>? {
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "%K == \(day.day) AND %K == \(day.month)", #keyPath(Event.day.day), #keyPath(Event.day.month))
        let sort = NSSortDescriptor(key: #keyPath(Event.startHour), ascending: true)
        let anotherSort = NSSortDescriptor(key: #keyPath(Event.isCompleted), ascending: true)
        request.sortDescriptors = [anotherSort, sort]
        let fetchEventsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: #keyPath(Event.isCompleted), cacheName: nil)
        fetchEventsController.delegate = delegate

            do {
                try fetchEventsController.performFetch()
                return fetchEventsController
                
            }   catch let error as NSError {
                print(FetchingErrors.errorFetchingEventsForToday(error))
                return nil
            }
        
    }
    
    public func saveEvent (_ eventStartHour: Int, _ eventStartMinute: Int, _ eventEndHour: Int, _ eventEndMinute: Int, _ eventDay: Day, _ eventProcedure: Procedure, _ eventCustomer: Customer, _ eventMaster: Master, _ note: String? = nil ) {

        //Classic approach
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "startHour == \(eventStartHour) AND startMinute == \(eventStartMinute)")
        do {
            let results = try managedObjectContext.fetch(request)
            if results.count > 0 {
                print("Theres already an event like this")
            } else {
                let newEvent = Event(context: managedObjectContext)
                newEvent.startHour = Int16(eventStartHour)
                newEvent.startMinute = Int16(eventStartMinute)
                newEvent.endHour = Int16(eventEndHour)
                newEvent.endMinute = Int16(eventEndMinute)
                newEvent.procedure = eventProcedure
                newEvent.customer = eventCustomer
                newEvent.master = eventMaster
                newEvent.isCompleted = false
                if note != nil {
                    newEvent.note = note
                }
                let day = DayOfWork(context: managedObjectContext)
                
                //Here day is definitely not nil, checked in calling of the function
                day.day = Int16(eventDay.day)
                day.month = Int16(eventDay.month)
                day.year = Int16(eventDay.year)
                newEvent.day = day
                
                CoreDataStack.shared.saveContext()
            }
        } catch let error as NSError {
            print(FetchingErrors.errorSavingEvent(error))
        }
    }
    
    
    public func deleteEvent(_ event: Event) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "SELF == %@", event)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let batchDelete = try managedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
            
            let deletedObjects : [AnyHashable : Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [managedObjectContext])
           
        } catch let error as NSError {
            print("Error deleting event: \(error), \(error.userInfo)")
        }
    }
    
    
    public func updateEvent (_ event: Event) {
        

        event.isCompleted = !event.isCompleted
        CoreDataStack.shared.saveContext()
        
    }
    
    
    
    
    
    
}


