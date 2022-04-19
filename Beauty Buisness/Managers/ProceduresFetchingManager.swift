//
//  ProceduresFetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation
import CoreData


class ProceduresFetchingManager {
    
    static let shared = ProceduresFetchingManager()
    
    private init () {}
    
    public func fetchExistingProcedure (procedureName: String?) -> [Procedure]? {
        
        guard let procedure = procedureName else {
            return nil
        }
        
        let request: NSFetchRequest<Procedure> = Procedure.fetchRequest()
        let salonType = UserDefaults.standard.string(forKey: "SALON-TYPE")
        request.predicate = NSPredicate(format: "%K == %@ AND %K CONTAINS [cd] %@", #keyPath(Procedure.salonType.type), salonType!, #keyPath(Procedure.name), procedure)
        
            do {
                let resultsFetch = try CoreDataStack.shared.context.fetch(request)
                return resultsFetch
            } catch let error as NSError {
                print(FetchingErrors.errorFetchingExistingProcedures(error))
                return nil
            }
        }
        
    
}
