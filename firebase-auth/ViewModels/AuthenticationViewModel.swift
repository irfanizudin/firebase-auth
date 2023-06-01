//
//  AuthenticationViewModel.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import Foundation
import SwiftUI
import GoogleSignIn
import AuthenticationServices
import Firebase


class AuthenticationViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var nonce: String = ""
    @Published var userApple: UserApple?
    
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @AppStorage("id") var id: String = ""
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("lastName") var lastName: String = ""
    @AppStorage("email") var email: String = ""


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
            isLoading = false
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
                print("bb")

            } else {

                withAnimation(.easeInOut) {
                    self.isSignedIn = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false

        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func signInWithAppleRequest(request: ASAuthorizationAppleIDRequest) {
        nonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func signInWithAppleCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let user):
            
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("error to get credential")
                return
            }
            
            authenticateAppleSignIn(credential: credential)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func authenticateAppleSignIn(credential: ASAuthorizationAppleIDCredential) {
        
        let id = credential.user
        let firstName = credential.fullName?.givenName
        let lastName = credential.fullName?.familyName
        let email = credential.email
        
        let user = UserApple(id: id, firstName: firstName, lastName: lastName, email: email)
        userApple = user
        print(userApple)

        self.id = id
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
        self.email = email ?? ""
        
        guard let token = credential.identityToken else {
            print("error get token")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error convert token to string")
            return
        }
        
        let appleCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: appleCredential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Login Apple success")
            self.isSignedIn = true
        }
        
        
    }
    
}
