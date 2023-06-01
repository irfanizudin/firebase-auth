//
//  AuthenticationViewModel.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import Foundation
import SwiftUI
import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoading: Bool = false
    
    func checkUserStatus() {
        user = Auth.auth().currentUser
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            print("has previous signin: ",user as Any)
        }
    }
    
    func signIn() {
                
            isLoading = true
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = configuration
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController
            else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                authenticateUser(user: result?.user, error: error)

            }
        
    }
    
    func authenticateUser(user: GIDGoogleUser?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let idToken = user?.idToken?.tokenString,
              let accessToken = user?.accessToken.tokenString else {
            return
        }
        
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                print(error.localizedDescription)
            } else {

                withAnimation(.easeInOut) {
                    UserDefaults.standard.setValue(true, forKey: "isSignedIn")
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.setValue(false, forKey: "isSignedIn")

        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
