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
    
    public var proceed: ((Date, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proceed = { [weak self] startingHour, endingHour in
            
            
            UserDefaults.standard.set(startingHour, forKey: "STARTING-HOUR")
            UserDefaults.standard.set(endingHour, forKey: "ENDING-HOUR")
            
            let mainScreenTabBarController = MainScreenTabBarController()
            mainScreenTabBarController.modalPresentationStyle = .overFullScreen
            self?.present(mainScreenTabBarController, animated: true)
            
        }
        
        setupSecondStepViewController()
        
    }
    
    private func setupSecondStepViewController () {
        let secondSetupViewController = UIHostingController(rootView: SecondStep(finalStep: proceed)).view!
        view.addSubview(secondSetupViewController)
        secondSetupViewController.frame = view.bounds
        
    }
    
}
