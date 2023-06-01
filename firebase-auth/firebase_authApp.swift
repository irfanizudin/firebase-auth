//
//  firebase_authApp.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI
import FirebaseCore

@main
struct firebase_authApp: App {
    
    @StateObject var vm = AuthenticationViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
//            LoginView()
                .environmentObject(vm)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
