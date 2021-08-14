//
//  AppDelegate.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 06.12.2020.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        
        Messaging.messaging().delegate = self
        UINavigationBar.appearance().shadowImage = UIColor.black.withAlphaComponent(0.3).navigationShadow()
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().tintColor = .black
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    
}
