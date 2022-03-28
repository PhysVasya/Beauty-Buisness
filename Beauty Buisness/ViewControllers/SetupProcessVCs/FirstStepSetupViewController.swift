//
//  SetupViewController1.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 27.03.2022.
//

import Foundation
import UIKit
import SwiftUI

class FirstStepSetupViewController: UIViewController {
    
    private let onboardingViewController = UIHostingController(rootView: OnboardingView())
    private var nextStep: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextStep = { [weak self] name in
            let secontStepVC = SecondStepSetupViewController()
            secontStepVC.title = name
            self?.navigationController?.pushViewController(secontStepVC, animated: true)
            UserDefaults.standard.set(name, forKey: "SalonName")
        }
        
        setupFirstStepViewController()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnBoarding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
    }
    
    private func presentOnBoarding() {
        let seenTutorial = UserDefaults.standard.bool(forKey: "SEEN-TUTORIAL")
        onboardingViewController.modalPresentationStyle = .formSheet
                
        if !seenTutorial {
            present(onboardingViewController, animated: true) {
                UserDefaults.standard.set(true, forKey: "SEEN-TUTORIAL")
            }
        }
        
    }
    
    private func setupFirstStepViewController() {
        let firstStepView = UIHostingController(rootView: FirstStep(nextStep: nextStep)).view!
        firstStepView.frame = view.bounds
        view.addSubview(firstStepView)
    }
    
    private func setupNavigationController () {
        navigationItem.title = "Настройка"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .myBackgroundColor
    }
}
