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
import FirebaseFirestore
import FirebaseStorage


class AuthenticationViewModel: ObservableObject {
    
    @Published var checkUser: User?
    @Published var isLoading: Bool = false
    @Published var nonce: String = ""
    @Published var user: UserModel?
    @Published var showImagePicker: Bool = false
    @Published var image: UIImage?
    
    @AppStorage("isSignedIn") var isSignedIn: Bool = false

    let firestore = Firestore.firestore()

    func checkUserStatus() {
        checkUser = Auth.auth().currentUser
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            print("has previous signin: ",user as Any)
        }
    }
    
    func signInWithGoogle() {
                
            isLoading = true
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = configuration
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController
            else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                authenticateGoogleSignIn(user: result?.user, error: error)

            }
        
    }
    
    func authenticateGoogleSignIn(user: GIDGoogleUser?, error: Error?) {
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

            } else {
                self.isLoading = false

                withAnimation(.easeInOut) {
                    self.isSignedIn = true
                }
                
                let uid = user?.userID
                let fullName = user?.profile?.name
                let email = user?.profile?.email
                let photoURL = user?.profile?.imageURL(withDimension: 200)?.absoluteString
                
                let user = UserModel(uid: uid, fullName: fullName, email: email, photoURL: photoURL)
                
                self.saveUserSignIn(user: user)
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
            
            let uid = credential.user
            let firstName = credential.fullName?.givenName ?? ""
            let lastName = credential.fullName?.familyName ?? ""
            let fullName = "\(firstName) \(lastName)"
            let email = credential.email
            
            let user = UserModel(uid: uid, fullName: fullName, email: email, photoURL: "")
            
            self.saveUserSignIn(user: user)
        }
        
    }
    
    func saveUserSignIn(user: UserModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
                
        if user.email == nil {
            updateAppleSignIn(user: user, userId: userId)

        } else {
            
            let data: [String: Any] = [
                "uid": user.uid ?? "",
                "fullName": user.fullName ?? "",
                "email": user.email ?? "",
                "photoURL": user.photoURL ?? "",
                "createdAt": Timestamp(date: Date()),
                "updatedAt": Timestamp(date: Date())
            ]
            
            firestore.collection("Users").document(userId).setData(data) { error in
                if let error = error {
                    print("error saving data to firestore: ", error.localizedDescription)
                } else {
                    print("successfully save data to firestore")
                }
            }

        }
        
        
    }
    
    func updateAppleSignIn(user: UserModel, userId: String) {
        let data: [String: Any] = [
            "uid": user.uid ?? "",
            "updatedAt": Timestamp(date: Date())
        ]
        
        firestore.collection("Users").document(userId).updateData(data) { error in
            if let error = error {
                print("error update Apple SignIn: ", error.localizedDescription)
            } else {
                print("Successfully update Apple SignIn")
            }
        }

    }
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        firestore.collection("Users").document(userId).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Failed to fetch data: ", error.localizedDescription)
                return
            }
            
            guard let document = snapshot?.data() else { return }
            
            let uid = document["uid"] as? String ?? ""
            let fullName = document["fullName"] as? String ?? ""
            let email = document["email"] as? String ?? ""
            let photoURL = document["photoURL"] as? String ?? ""
            
            let user = UserModel(uid: uid, fullName: fullName, email: email, photoURL: photoURL)
            self.user = user
            
            print(user)
            
        }
        
    }
    
    func saveImageToStorage() {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: filename)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData) { metadata, error in
            if let error = error {
                print("Failed to save image: ", error.localizedDescription)
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to download URL: ", error.localizedDescription)
                    return
                }
                
                print("Successfully download URL: ", url?.absoluteString as Any)
            }
        }
    }
    
}
