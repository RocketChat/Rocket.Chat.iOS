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
    @objc dynamic var serverURL = ""
    var serverApiURL: String {
        return serverURL
            .replacingOccurrences(of: "wss://", with: "https://")
            .replacingOccurrences(of: "/websocket", with: "")
    }
    @objc dynamic var settings: AuthSettings?

    // Token
    @objc dynamic var token: String?
    @objc dynamic var tokenExpires: Date?
    @objc dynamic var lastAccess: Date?
    @objc dynamic var lastSubscriptionFetch: Date?

    // User
    @objc dynamic var userId: String?

    // Subscriptions
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }
}
