//
//  ViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 26.03.2022.
//

import UIKit
import SwiftUI

class MainScreenTabBarController: UITabBarController {
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //After loading main screen, no need to go back to onboarding.
        UserDefaults.standard.set(true, forKey: "SEEN-TUTORIAL")
        view.backgroundColor = .myBackgroundColor
        setupTabBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    private func setupTabBar () {
        
        //setting this appearance let us visually differ the starting of tabBarVC
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .mySecondaryAccentColor
        tabBar.scrollEdgeAppearance = appearance
        
        //Setuping TabBar
        let vc1 = UINavigationController(rootViewController: MainViewController())
        let vc2 = MainViewController()
        vc1.navigationBar.prefersLargeTitles = true
        vc1.title = "Главная"
        vc2.title = "Записать"
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "square.and.pencil")
        setViewControllers([vc1, vc2], animated: false)
        
    }
    
    
    
    
    
}


