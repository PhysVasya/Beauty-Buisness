//
//  Extensions.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    
    open class var myAccentColor: UIColor? {
        return UIColor(named: "AccentColor")
    }
    
    open class var myBackgroundColor: UIColor? {
        return UIColor(named: "BackgroundColor")
    }
    
    open class var mySecondaryAccentColor: UIColor? {
        return UIColor(named: "SecondaryAccentColor")
    }
    
    open class var myHighlightColor: UIColor? {
        return UIColor(named: "HighlightColor")
    }
}

extension Color {
    
    public static var myAccentColor : Color {
        return Color("AccentColor")
    }
    
    public static var myBackgroundColor : Color {
        return Color("BackgroundColor")
    }
    
    public static var mySecondaryAccentColor : Color {
        return Color("SecondaryAccentColor")
    }
    
    public static var myHightLightColor: Color {
        return Color("HighlightColor")
    }
    
}

extension Int {
    
    public static var startingHour: Int {
        return UserDefaults.standard.integer(forKey: "STARTING-HOUR")
    }
    
    public static var startingMinute: Int {
        return UserDefaults.standard.integer(forKey: "STARTING-MINUTE")
    }
    
    public static var endingHour: Int {
        return UserDefaults.standard.integer(forKey: "ENDING-HOUR")
    }
    
    public static var endingMinute: Int {
        return UserDefaults.standard.integer(forKey: "ENDING-MINUTE")
    }
    
}

extension UserDefaults {
    
    public static func setNewStartingTime (hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: "STARTING-HOUR")
        UserDefaults.standard.set(minute, forKey: "STARTING-MINUTE")
    }
    
    public static func setNewEndingTime (hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: "ENDING-HOUR")
        UserDefaults.standard.set(minute, forKey: "ENDING-MINUTE")
    }
}

extension UIDatePicker {
    
    var hour: Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.hour], from: self.date).hour
    }
    
    var minute: Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.minute], from: self.date).minute
    }
    
    
    
    
}

extension UITextField {
    
    public var textFieldIndexPath: IndexPath {
        if self.tag == 0 {
            return IndexPath(row: 0, section: 0)
        } else {
            return IndexPath(row: 0, section: 1)
        }
    }
    
    
}

extension DateComponents {
    
    var workingDay: Day {
        return Day(day: self.day!, month: self.month!, year: self.year!)
    }
    
}

extension Date {
    
    public static var now: Date {
        let date = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return Calendar.current.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: date)!
    }
    
    public static var today: DateComponents {
        return Calendar.current.dateComponents([.day, .month, .year], from: Date())
    }
    
    public static var tomorrow: DateComponents {
        return Calendar.current.dateComponents([.day, .month, .year], from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    }
    
     static func todayAsDay () -> Day {
         return Day(day: today.day!, month: today.month!, year: today.year!)
    }
    
    static func tomorrowAsDay () -> Day {
        return Day(day: tomorrow.day!, month: tomorrow.month!, year: tomorrow.year!)
   }
}

extension Day {
    
    public func dateFormatted () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM"
        let dateFromComponents = DateComponents(year: year, month: month, day: day)
        let date = Calendar.current.date(from: dateFromComponents)!
        return formatter.string(from: date).capitalized
    }
    
    public func getDate () -> Date? {
        
        let components = DateComponents(year: self.year, month: self.month, day: self.day)
        return Calendar.current.date(from: components)
    }
    
}

extension DayOfWork {
    
    public func dateFormatted () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM"
        let dateFromComponents = DateComponents(year: Int(year), month: Int(month), day: Int(day))
        let date = Calendar.current.date(from: dateFromComponents)!
        return formatter.string(from: date).capitalized
    }
}

extension UIDatePicker {
    
    public static var forNewEvent: UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = 5
        return picker
    }
    
}



