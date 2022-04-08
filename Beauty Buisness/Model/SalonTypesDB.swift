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
    
    static let shared = SalonTypesDB()
    
    private let viewContext = CoreDataStack.shared.context
    private let types = ["Эпиляция", "Ноготочки", "Визажыст"]
    private let epilationProcedures = ["Шугаринг", "Электроэпиляция", "Восковая эпиляция", "Лазерная эпиляция"]
    private let epilationZones = ["Бикини", "Лысина", "Джеппа", "Ляшки"]
    
    private init () {}
    
    public var salonTypes: [SalonType] = []
    @Published private(set) var procedures: [Procedure] = []
    
    public func createAndSaveSalonTypes () {
        
        let managedSalonType = SalonType(context: viewContext)
        managedSalonType.type = types[0]
        
        epilationProcedures.forEach { procedure in
            let managedProcedure = Procedure(context: viewContext)
            managedProcedure.name = procedure
            managedProcedure.salonType = managedSalonType
            
            epilationZones.forEach { zone in
                let managedZone = ProcedureZone(context: viewContext)
                managedZone.name = zone
                managedZone.procedure = managedProcedure
            }
        }
        CoreDataStack.shared.saveContext()
        fetchSalonTypes()
    }
    
    private func fetchSalonTypes () {
        
        let request: NSFetchRequest<SalonType> = SalonType.fetchRequest()
        
        do {
            let result = try viewContext.fetch(request)
            salonTypes = result

        } catch let error as NSError {
            print("Error fetching salonTypes \(error), \(error.userInfo)")
        }
        
    }
    
    public func fetchProceduresForSalonType (_ type: SalonType) {
        
        let request: NSFetchRequest<Procedure> = Procedure.fetchRequest()
        
        do {
            let procedures = try viewContext.fetch(request)
            let mappedProcedures = procedures.compactMap({ proc -> Procedure? in  proc.salonType == type ? proc : nil })
            self.procedures = mappedProcedures
        } catch let error as NSError {
            print("Error fetching procedures for salon type: \(error), \(error.userInfo)")
        }
        
    }
    
    
}
