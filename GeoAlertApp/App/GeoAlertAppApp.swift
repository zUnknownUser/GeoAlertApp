
//  GeoAlertAppApp.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import UIKit
import SwiftUI
import CoreLocation
import FirebaseCore

@main
struct GeoAlertAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoading {
                SplashView()
                    .environmentObject(authViewModel)
            } else {
                if authViewModel.user != nil {
                    if authViewModel.profileCompleted {
                        ContentView()
                            .environmentObject(authViewModel)
                    } else {
                        CompleteProfileView()
                            .environmentObject(authViewModel)
                    }
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
