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
            
            AsyncImage(url: userHome?.profile?.imageURL(withDimension: 100)) { image in
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
            
            Text(userHome?.profile?.name ?? vm.firstName + " " + vm.lastName )
                .font(.title.bold())
            
            Text(userHome?.profile?.email ?? vm.email )
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
            print(vm.user?.uid ?? "")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
