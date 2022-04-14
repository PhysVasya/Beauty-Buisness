//
//  Contact.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 14.04.2022.
//

import Foundation
import Contacts
import UIKit


class Contact {
    
    var name: String
    var phoneNumber: CNLabeledValue<CNPhoneNumber>?
    var image: UIImage?
    
    init(name: String) {
        self.name = name
    }
    
}

extension Contact {
    
    convenience init?(contact: CNContact) {
        let firstName = contact.givenName
        let lastName = contact.familyName
        
        self.init(name: firstName + " " + lastName)
        if let contactPhone = contact.phoneNumbers.first {
            phoneNumber = contactPhone
        }
        if let contactImageData = contact.imageData {
            let contactImage = UIImage(data: contactImageData, scale: 1)
            image = contactImage?.imageResized(to: CGSize(width: 44, height: 44))
            
        } else {
            image = UIImage(systemName: "person.circle")?.imageResized(to: CGSize(width: 44, height: 44))
            
        }
    }
}

extension UIImage {
    func imageResized (to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
