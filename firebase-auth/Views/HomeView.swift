//
//  HomeView.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var vm: AuthenticationViewModel
    
    
    let userHome = GIDSignIn.sharedInstance.currentUser
    
    var body: some View {
        VStack {
            Text("Welcome 🥰")
                .font(.largeTitle.bold())
            
            if vm.user?.photoURL == "" {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: vm.user?.photoURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }

            }
            
            Text(vm.user?.fullName ?? "")
                .font(.title.bold())
            
            Text(vm.user?.email ?? "")
                .font(.body)
                .foregroundColor(.gray)
            
            Button {
                vm.signOut()
            } label: {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.primary)
                    .cornerRadius(10)
                
            }
            .padding(.top, 200)

        }
        .padding(.horizontal, 30)
        .onAppear {
            vm.fetchUserData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
