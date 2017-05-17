//
//  AuthHandler.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class AuthHandler: AuthDelegate {
    func didLogout() {
        GIDSignIn.sharedInstance().signOut()
    }
}
