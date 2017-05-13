//
//  Auth.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class Auth: Object {
    // Server
    dynamic var serverURL = ""
    dynamic var settings: AuthSettings?

    // Token
    dynamic var token: String?
    dynamic var tokenExpires: Date?
    dynamic var lastAccess: Date?
    dynamic var lastSubscriptionFetch: Date?

    // User
    dynamic var userId: String?

    // Subscriptions
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }
}
