//
//  Auth.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class Auth: Object {
    // Server
    dynamic var serverURL = ""

    // Token
    dynamic var token: String?
    dynamic var tokenExpires: NSDate?
    dynamic var lastAccess: NSDate?

    // User
    dynamic var userId: String?
    
    // Subscriptions
    var subscriptions = List<Subscription>()
    
    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }
}