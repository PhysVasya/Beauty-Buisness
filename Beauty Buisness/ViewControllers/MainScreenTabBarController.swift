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
    
    private func setupTabBar () {
        
        //setting this appearance let us visually differ the starting of tabBarVC
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .mySecondaryAccentColor
        tabBar.scrollEdgeAppearance = appearance
        
        //Setuping TabBar
        let vc1 = UINavigationController(rootViewController: EventsViewController())
        let vc2 = UINavigationController(rootViewController: CustomersViewController())
        let vc3 = UINavigationController(rootViewController: MastersViewController())
        let vc4 = UINavigationController(rootViewController: SettingsViewController())
        vc1.navigationBar.prefersLargeTitles = true
        vc1.title = "Запись"
        vc2.title = "Клиенты"
        vc3.title = "Мастера"
        vc4.title = "Настройки"
        vc1.tabBarItem.image = UIImage(systemName: "square.and.pencil")
        vc2.tabBarItem.image = UIImage(systemName: "person.3")
        vc3.tabBarItem.image = UIImage(systemName: "brain.head.profile")
        vc4.tabBarItem.image = UIImage(systemName: "gear")
        setViewControllers([vc1, vc2, vc3, vc4], animated: false)
    }
}


