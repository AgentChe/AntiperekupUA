//
//  AppDelegate.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 06.12.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
}
