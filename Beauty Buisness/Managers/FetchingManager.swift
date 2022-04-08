//
//  FetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 05.04.2022.
//

import Foundation
import CoreData


class FetchingManager {
    
    static let shared = FetchingManager()
    
    public let managedObjectContext = CoreDataStack(modelName: "Beauty_Buisness").context
    
    private init () {}
    
    private func saveEvent (event: Event?) {
        
        guard let event = event else {
            return
        }

        //Classic approach
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        
        do {
           let results = try managedObjectContext.fetch(request)
            if results.count > 0 {
                
            }

        } catch let error as NSError {
            print("Error saving events \(error), \(error.userInfo)")
        }
        
        
    }
    
}
