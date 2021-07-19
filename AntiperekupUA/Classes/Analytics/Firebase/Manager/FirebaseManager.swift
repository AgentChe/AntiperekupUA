//
//  FirebaseManager.swift
//  AV
//
//  Created by Andrey Chernyshev on 11.06.2021.
//

import Firebase

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
}

// MARK: Public
extension FirebaseManager {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
    }
}
