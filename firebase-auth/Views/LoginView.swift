//
//  LoginView.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var vm: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Hi There 👋")
                .font(.largeTitle.bold())
            if vm.isLoading {
                ProgressView()
            } else {
                VStack {
                    HStack {
                       Image("google-logo")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Text("Sign In with Google")
                            .font(.callout)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black)
                    }
                    .overlay {
                        GoogleSignInButton()
                            .onTapGesture {
                                vm.signIn()
                            }
                            .blendMode(.overlay)
                    }

                    HStack {
                       Image(systemName: "apple.logo")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Text("Sign In with Apple")
                            .font(.callout)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black)
                    }
                    .overlay {
                        SignInWithAppleButton { request in
                            
                            vm.signInWithAppleRequest(request: request)
                            
                        } onCompletion: { result in
                            
                            vm.signInWithAppleCompletion(result: result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .blendMode(.overlay)
                    }
                    .padding(.top)

  
                }
                .padding(.horizontal, 20)

            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}
