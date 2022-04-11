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
    
    public func fetchEventsForToday (_ day: Date) async -> NSFetchedResultsController<Event> {
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let currentDay = DayOfWork(context: managedObjectContext)
        currentDay.date = Date()
//        request.predicate = NSPredicate(format: "day == \(currentDay)")
        let sort = NSSortDescriptor(key: #keyPath(Event.startHour), ascending: true)
        request.sortDescriptors = [sort]
        let fetchEventsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return await withCheckedContinuation { continuation in
            do {
                try fetchEventsController.performFetch()
                continuation.resume(returning: fetchEventsController)
                
            }   catch let error as NSError {
                print(FetchingErrors.errorFetchingEventsForToday(error))
            }
        }
    }
    
    public func saveEvent (_ eventStartHour: Int, _ eventStartMinute: Int, _ eventEndHour: Int, _ eventEndMinute: Int, _ eventProcedure: Procedure, _ eventCustomer: Customer, _ eventMaster: Master ) {

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
                let day = DayOfWork(context: managedObjectContext)
                day.date = Date()
                
                CoreDataStack.shared.saveContext()
            }
        } catch let error as NSError {
            print(FetchingErrors.errorSavingEvent(error))
        }
    }
    
    
    public func deleteEvent(_ event: Event) {
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "SELF == \(event)")
        do {
            let results = try managedObjectContext.fetch(request)
            print(results)
            if results.count > 0 {
                managedObjectContext.delete(event)
                CoreDataStack.shared.saveContext()
            }
        } catch let error as NSError {
            print("Error deleting event: \(error), \(error.userInfo)")
        }
    }
    
    
   
    
    
    
    
    
    
}


