//
//  ContentView.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AuthenticationViewModel
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    
    var body: some View {
        Group {
            if isSignedIn {
                HomeView()
                    .environmentObject(vm)
            } else {
                LoginView()
                    .environmentObject(vm)
            }

        }
        .onAppear {
            vm.checkUserStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
