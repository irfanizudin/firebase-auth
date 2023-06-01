//
//  GoogleSignInButton.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 17/05/23.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    
    @Environment(\.colorScheme) var colorScheme
    
    private var button = GIDSignInButton()
    
    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = colorScheme == .dark ? .dark : .light
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        button.colorScheme = colorScheme == .dark ? .dark : .light
    }
    
    
}

struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButton()
    }
}
