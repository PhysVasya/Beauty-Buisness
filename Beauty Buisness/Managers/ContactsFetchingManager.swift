//
//  ContactsFetchingManager.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 14.04.2022.
//

import Foundation
import Contacts

class ContactsFetchingManager {
    
    static let shared = ContactsFetchingManager()
    
    private let contactsStore = CNContactStore()
    private let keys: [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor
    ]
    
    public func fetchUserContacts () async -> [Contact]?  {
        
        let request: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
       return await withCheckedContinuation { continuation in
           do {
               var contacts: [Contact] = []
               try contactsStore.enumerateContacts(with: request, usingBlock: { contact, pointer in
                   if let contact = Contact(contact: contact) {
                       contacts.append(contact)
                   }
               })
               
               continuation.resume(returning: contacts)
           } catch let error as NSError {
               continuation.resume(returning: nil)
               print("Error fetching all containers \(error)")
           }
        }
        
        
    }
    
}
