//
//  User.swift
//  firebase-auth
//
//  Created by Irfan Izudin on 01/06/23.
//

import Foundation

struct UserApple {
    let id: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    
    init(id: String?, firstName: String?, lastName: String?, email: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
