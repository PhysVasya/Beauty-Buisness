//
//  SecondStepSetupViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 30.03.2022.
//

import Foundation
import UIKit
import SwiftUI


class SecondStepSetupViewController: UIViewController {
    
    public var proceedToMainScreen: ((Date, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Runs when tapping "Continue" button from the second step
        
        proceedToMainScreen = { [weak self] startingHourDate, endingHourDate in
            
            let startingDateComps = Calendar.current.dateComponents([.hour, .minute], from: startingHourDate)
            let endingDateComps = Calendar.current.dateComponents([.hour, .minute], from: endingHourDate)
            
            guard let startingHour = startingDateComps.hour,
                  let startingMinute = startingDateComps.minute,
                  let endingHour = endingDateComps.hour,
                  let endingMinute = endingDateComps.minute else { return }
            
            //Saving working hours which later can be accessed and changed in the settings from right bar button item
            UserDefaults.standard.set(startingHour, forKey: "STARTING-HOUR")
            UserDefaults.standard.set(startingMinute, forKey: "STARTING-MINUTE")
            UserDefaults.standard.set(endingHour, forKey: "ENDING-HOUR")
            UserDefaults.standard.set(endingMinute, forKey: "ENDING-MINUTE")
            
            //No need for continuing navigationController flow, present new.
            let mainScreenTabBarController = MainScreenTabBarController()
            mainScreenTabBarController.modalPresentationStyle = .overFullScreen
            self?.present(mainScreenTabBarController, animated: true)
            
        }
        
        setupSecondStepViewController()
        
    }
    
    private func setupSecondStepViewController () {
        let secondSetupViewController = UIHostingController(rootView: SecondStep(finalStep: proceedToMainScreen)).view!
        view.addSubview(secondSetupViewController)
        secondSetupViewController.frame = view.bounds
        
    }
    
}
