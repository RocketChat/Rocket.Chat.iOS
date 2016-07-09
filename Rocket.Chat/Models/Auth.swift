//
//  Auth.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class Auth: BaseModel {
    // Server
    dynamic var serverURL = ""

    // Token
    dynamic var token: String?
    dynamic var tokenExpires: NSDate?

    // User
    dynamic var userId: String?
    
    // Access
    dynamic var lastAccess: NSDate?
    
    // Subscriptions
    var subscriptions = List<Subscription>()
}