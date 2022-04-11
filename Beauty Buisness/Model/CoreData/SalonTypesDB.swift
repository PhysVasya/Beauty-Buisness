//
//  SalonTypesDB.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 07.04.2022.
//

import Foundation
import CoreData
import Combine


class SalonTypesDB: ObservableObject {
    
    private enum SalonTypesFetchingErrors: LocalizedError {
        case fetchTypesError(NSError)
        case fetchProceduresError(NSError)
        case saveProceduresError(NSError)
        case saveTypesError(NSError)
        case deleteProceduresError(NSError)
        case deleteTypesError(NSError)
        
        var errorDescription: String? {
            switch self {
            case .fetchTypesError(let nSError):
                return ("Error fetching salon types: \(nSError), \(nSError.userInfo)")
            case .fetchProceduresError(let nSError):
                return ("Error fetching procedures: \(nSError), \(nSError.userInfo)")
            case .saveProceduresError(let nSError):
                return ("Error saving procedures: \(nSError), \(nSError.userInfo)")
            case .saveTypesError(let nSError):
                return ("Error saving salon types: \(nSError), \(nSError.userInfo)")
            case .deleteProceduresError(let nSError):
                return ("Error deleting procedures: \(nSError), \(nSError.userInfo)")
            case .deleteTypesError(let nSError):
                return ("Error deleting salon types: \(nSError), \(nSError.userInfo)")
            }
        }
      
    }
    
    static let shared = SalonTypesDB()
    
    private let types = ["Эпиляция", "Ноготочки", "Визажыст"]
    private let epilationProcedures = ["Шугаринг", "Электроэпиляция", "Восковая эпиляция", "Лазерная эпиляция"]
    private let epilationZones = ["Бикини", "Лысина", "Джеппа", "Ляшки"]
    
    private init () {}
    
    @Published public var salonTypes: [SalonType] = []
    @Published public var procedures: [Procedure] = []
    
    public func createAndSaveSalonTypes () {
        
        let managedSalonType = SalonType(context: CoreDataStack.shared.context)
        managedSalonType.type = types[0]
        
        epilationProcedures.forEach { procedure in
            let managedProcedure = Procedure(context: CoreDataStack.shared.context)
            managedProcedure.name = procedure
            managedProcedure.salonType = managedSalonType
            
            epilationZones.forEach { zone in
                let managedZone = ProcedureZone(context: CoreDataStack.shared.context)
                managedZone.name = zone
                managedZone.procedure = managedProcedure
            }
        }
        CoreDataStack.shared.saveContext()
        fetchSalonTypes()
    }
    
    public func fetchSalonTypes () {
        
        let request: NSFetchRequest<SalonType> = SalonType.fetchRequest()
        
        do {
            let result = try CoreDataStack.shared.context.fetch(request)
            salonTypes = result

        } catch let error as NSError {
            print(SalonTypesFetchingErrors.fetchTypesError(error))
        }
        
    }
    
    public func fetchProceduresForSalonType () {
        
        let chosenSalonType = UserDefaults.standard.string(forKey: "SALON-TYPE")
        
        let request: NSFetchRequest<Procedure> = Procedure.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Procedure.salonType.type), chosenSalonType!)

        do {
            let procedures = try CoreDataStack.shared.context.fetch(request)
            self.procedures = procedures
        } catch let error as NSError {
            print(SalonTypesFetchingErrors.fetchProceduresError(error))
        }
        
    }
    
    public func deleteProcedure (_ delete: Procedure) {
       
        CoreDataStack.shared.context.delete(delete)
            CoreDataStack.shared.saveContext()
        
    }
    
    public func addProcedure (procedureName: String, for salonType: SalonType) {
        
        let newProcedure = Procedure(context: CoreDataStack.shared.context)
        newProcedure.name = procedureName
        
        salonType.addToProcedures(newProcedure)
        CoreDataStack.shared.saveContext()
        fetchProceduresForSalonType()
        
    }
    
    public func addNewSalonType (salonName: String) {
        
        let salon = SalonType(context: CoreDataStack.shared.context)
        salon.type = salonName
        
        CoreDataStack.shared.saveContext()
        fetchSalonTypes()
    }

}
