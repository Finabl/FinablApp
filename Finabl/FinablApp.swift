//
//  FinablApp.swift
//  Finabl
//
//  Created by Mehdi Hussain on 12/21/24.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FinablApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        
        WindowGroup {
            OnboardingView() //change this to a view that chooses which view lol
        }
    }
}
