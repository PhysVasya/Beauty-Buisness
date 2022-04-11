//
//  Errors.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 11.04.2022.
//

import Foundation

public enum FetchingErrors: LocalizedError {
    case errorFetchingMasters(NSError)
    case errorFetchingCustomers(NSError)
    case errorFetchingExistingCustomer(NSError)
    case errorFetchingExistingMaster(NSError)
    case errorFetchingEventsForToday(NSError)
    case errorFetchingExistingProcedures(NSError)
    case errorSavingEvent(NSError)
    
    public var errorDescription: String? {
        switch self {
        case .errorFetchingMasters(let nSError):
            return "Error fetching masters: \(nSError), \(nSError.userInfo)"
        case .errorFetchingCustomers(let nSError):
            return "Error fetching customers: \(nSError), \(nSError.userInfo)"
        case .errorFetchingExistingCustomer(let nSError):
            return "Error fetching existing customer: \(nSError), \(nSError.userInfo)"
        case .errorFetchingExistingMaster(let nSError):
            return "Error fetching existing master: \(nSError), \(nSError.userInfo)"
        case .errorFetchingEventsForToday(let nSError):
            return "Error fetching events for today: \(nSError), \(nSError.userInfo)"
        case .errorFetchingExistingProcedures(let nSError):
            return "Error fetching existing procedures: \(nSError), \(nSError.userInfo)"
        case .errorSavingEvent(let nSError):
            return "Error saving new event: \(nSError), \(nSError.userInfo)"
        }
    }


}
