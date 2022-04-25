//
//  EventDetailItem.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 25.04.2022.
//

import Foundation

class EventDetailItem: Hashable {
    
    var item: Any?
    
    var id = UUID()
    
    static func == (lhs: EventDetailItem, rhs: EventDetailItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init (item: Any?) {
        self.item = item
    }
    
}
