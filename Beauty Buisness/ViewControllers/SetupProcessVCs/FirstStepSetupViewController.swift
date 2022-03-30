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
        
        //Closure from 1st setup step saves the name of salon, brings in the main screen
        nextStep = { [weak self] name in
            let secondStepSetup = SecondStepSetupViewController()
            secondStepSetup.title = name
            secondStepSetup.modalPresentationStyle = .fullScreen
            self?.navigationController?.pushViewController(secondStepSetup, animated: true)
            UserDefaults.standard.set(name, forKey: "SALON-NAME")
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
        onboardingViewController.modalPresentationStyle = .formSheet
        onboardingViewController.isModalInPresentation = true
        present(onboardingViewController, animated: true)
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
