//
//  LoadingView.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 02/06/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .background(.white)
            .cornerRadius(10)
        }
        .opacity(self.isShowing ? 1 : 0)

    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isShowing: .constant(true))
    }
}
