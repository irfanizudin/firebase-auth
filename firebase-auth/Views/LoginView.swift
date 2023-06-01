//
//  LoginView.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Hi There 👋")
                .font(.largeTitle.bold())
            if vm.isLoading {
                ProgressView()
            } else {
                HStack {
                   Image("google-logo")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    Text("Google Sign In")
                        .font(.callout)
                }
                .foregroundColor(.white)
                .padding()
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

            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
