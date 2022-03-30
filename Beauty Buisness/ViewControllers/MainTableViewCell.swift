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
        
        //Accessing values from saved ones
        let startingHour = UserDefaults.standard.object(forKey: "STARTING-HOUR") as! Date
        let endingHour = UserDefaults.standard.object(forKey: "ENDING-HOUR") as! Date
        
        
        let calendar = Calendar(identifier: .gregorian)
        
        //Getting the number of hours and minutes every working day.
        let workingDay = calendar.dateComponents([.hour, .minute], from: startingHour, to: endingHour)
        guard let hours = workingDay.hour,
                //Minutes not needed I think, but let them be for now.
              let minutes = workingDay.minute,
              //Those are easy understandable.
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
    
    //REVIEW LATER !
    
    let startingHour: Int
    let endingHour: Int
    let startingMinute: Int
    let endingMinute: Int
    let hours: Range<Int>
    
}
