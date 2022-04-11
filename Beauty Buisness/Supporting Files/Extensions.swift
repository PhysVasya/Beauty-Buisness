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
        return UIColor(named: "HightlightColor")
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
        return Color("HightlightColor")
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

