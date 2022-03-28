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
    
}
