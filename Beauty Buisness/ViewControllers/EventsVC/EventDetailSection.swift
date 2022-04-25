//
//  EventDetailSection.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 25.04.2022.
//

import Foundation

class EventDetailSection: Hashable {
    
    var id = UUID()
    var title: String? {
        return event?.master?.name
    }
    var event: Event?
    
    static func == (lhs: EventDetailSection, rhs: EventDetailSection) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init (event: Event?) {
        self.event = event
    }
    
}


