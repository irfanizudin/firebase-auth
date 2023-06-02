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
    
    var body: some View {
        VStack {
            Text("Welcome 🥰")
                .font(.largeTitle.bold())
            
            Group {
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
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

                }
                
                                
            }
            .onTapGesture {
                vm.showImagePicker = true
            }
            
            Text("Change photo")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
                .padding(.bottom)
                .onTapGesture {
                    vm.showImagePicker = true
                }
            
            Text(vm.user?.fullName ?? "")
                .font(.title.bold())
            
            Text(vm.user?.email ?? "")
                .font(.body)
                .foregroundColor(.gray)
            
            Button {
                vm.saveImageToStorage()
            } label: {
                Text("Save Photo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(vm.image == nil ? .gray : .blue)
                    .cornerRadius(10)
                
            }
            .padding(.top, 200)
            .disabled(vm.image == nil ? true : false)

            Button {
                vm.signOut()
            } label: {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .cornerRadius(10)
                
            }
            .padding(.top, 10)
            
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 30)
        .onAppear {
            vm.fetchUserData()
        }
        .sheet(isPresented: $vm.showImagePicker) {
            ImagePicker(image: $vm.image)
        }
        .alert(vm.alertMessage, isPresented: $vm.showUpdatedPhotoAlert) {
            Button("OK", action: {})
        }
        .overlay {
            LoadingView(isShowing: $vm.isShowLoading)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}
