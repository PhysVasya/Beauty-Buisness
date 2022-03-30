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
        
        proceedToMainScreen = { [weak self] startingHour, endingHour in
  
            //Saving working hours which later can be accessed and changed in the settings from right bar buttom item
            UserDefaults.standard.set(startingHour, forKey: "STARTING-HOUR")
            UserDefaults.standard.set(endingHour, forKey: "ENDING-HOUR")
            
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
