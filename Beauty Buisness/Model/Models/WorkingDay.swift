//
//  WorkingDay.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 03.04.2022.
//

import Foundation


struct WorkingDay {
    
    enum WorkingDayCompilingErrors: LocalizedError {
        case errorGettingDates
        case unableToCalculateHours
        
        var errorDescription: String? {
            switch self {
            case .errorGettingDates:
                return "Error getting dates from defaults."
            case .unableToCalculateHours:
                return "Unable to calculate working hours."
            }
        }
    }
    
    //REVIEW LATER !
    
    let startingHour: Int
    let endingHour: Int
    let startingMinute: Int
    let endingMinute: Int
    let hours: Range<Int>
    
    //Returns hours in day with custom created type for each row of tableView. These are later used to change working hours later and add events.
    static func generateHoursInWorkingDay() throws -> WorkingDay {
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        //Accessing values from saved ones
        let startingHour = Int.startingHour
        let endingHour = Int.endingHour
        let startingMinute = Int.startingMinute
        let endingMinute = Int.endingMinute
        
       guard let startingWorkingTime = calendar.date(bySettingHour: startingHour, minute: startingMinute, second: 0, of: calendar.startOfDay(for: Date.now)),
             let endingWorkingTime = calendar.date(bySettingHour: endingHour, minute: endingMinute, second: 0, of: calendar.startOfDay(for: Date.now)) else { throw WorkingDayCompilingErrors.errorGettingDates }
        
        //Getting the number of hours and minutes every working day.
        let workingDay = calendar.dateComponents([.hour, .minute], from: startingWorkingTime, to: endingWorkingTime)
        guard let hours = workingDay.hour else { throw WorkingDayCompilingErrors.unableToCalculateHours }
        
        return WorkingDay(startingHour: startingHour, endingHour: endingHour, startingMinute: startingMinute, endingMinute: endingMinute, hours: Range(0...hours))
    }
    
    
    
}
