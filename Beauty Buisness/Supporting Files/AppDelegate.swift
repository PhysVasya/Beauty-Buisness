//
//  AppDelegate.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 26.03.2022.
//

import UIKit
import CoreData
import SwiftUI
import Contacts

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Presents onboarding every launch
//        UserDefaults.standard.set(false, forKey: "SEEN-TUTORIAL")
        
        let seenTutorial = UserDefaults.standard.bool(forKey: "SEEN-TUTORIAL")
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        if !seenTutorial {
            CoreDataStack.shared.clearDB()
            SalonTypesDB.shared.createAndSaveSalonTypes()
            
            window.rootViewController = UIHostingController(rootView: NameSetupView())
        } else {
            window.rootViewController = MainScreenTabBarController()
        }
        window.makeKeyAndVisible()
        self.window = window
        
        CNContactStore().requestAccess(for: .contacts) { access, error in
//            print(access)
        }
            
//      print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

