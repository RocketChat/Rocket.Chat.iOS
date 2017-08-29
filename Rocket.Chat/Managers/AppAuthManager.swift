//
//  AppAuthManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/29/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class AppAuthManager: AuthManager {

    override func logout(completion: @escaping VoidCompletion) {
        super.logout {
            GIDSignIn.sharedInstance().signOut()
            completion()
        }
    }

}
