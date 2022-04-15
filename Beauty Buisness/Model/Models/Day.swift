//
//  Day.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 14.04.2022.
//

import Foundation

struct Day: Equatable {
    let day: Int?
    let month: Int?
    let year: Int?
    
    public static func == (lhs: Day, rhs: Day) -> Bool {
        return
            rhs.day == lhs.day &&
            rhs.month == lhs.month &&
            rhs.year == rhs.year
    }
}


