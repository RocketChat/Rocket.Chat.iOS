//
//  AuthManagerCurrentUser.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension AuthManager {
    /**
     - returns: Current user object, if exists.
     */
    static func currentUser(realm: Realm? = Realm.current) -> User? {
        return isAuthenticated(realm: realm)?.user
    }
}
