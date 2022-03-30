//
//  MainViewControllerTableCell.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 30.03.2022.
//

import Foundation
import UIKit


class MainTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "MainTableViewCellIdentifier"

    
    //Returns hours in day with custom created type for each row of tableView. These are later used to change working hours later and add events.
    static func generateHoursInWorkingDay() -> WorkingDay {
        
        let startingHour = UserDefaults.standard.object(forKey: "STARTING-HOUR") as! Date
        let endingHour = UserDefaults.standard.object(forKey: "ENDING-HOUR") as! Date
        
        
        let calendar = Calendar(identifier: .gregorian)
        let workingDay = calendar.dateComponents([.hour, .minute], from: startingHour, to: endingHour)
        guard let hours = workingDay.hour,
              let minutes = workingDay.minute,
              let todayStartingHour = calendar.dateComponents([.hour], from: startingHour).hour,
              let todayEndingHour = calendar.dateComponents([.hour], from: endingHour).hour,
              let todayStartingMinute = calendar.dateComponents([.minute], from: startingHour).minute,
              let todayEndingMinute = calendar.dateComponents([.minute], from: endingHour).minute else {
            fatalError("Error generating working day")
        }
        

        return WorkingDay(startingHour: todayStartingHour, endingHour: todayEndingHour, startingMinute: todayStartingMinute, endingMinute: todayEndingMinute, hours: Range(0...hours))
            
    }
}


struct WorkingDay {
    
    let startingHour: Int
    let endingHour: Int
    let startingMinute: Int
    let endingMinute: Int
    let hours: Range<Int>
    
}
