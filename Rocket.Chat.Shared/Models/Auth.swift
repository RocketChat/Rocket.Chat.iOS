//
//  Auth.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

/// Server authentication settings
public class Auth: Object {
    // Server
    public dynamic var serverURL = ""
    public dynamic var settings: AuthSettings?

    // Token
    dynamic var token: String?
    dynamic var tokenExpires: Date?
    public dynamic var lastAccess: Date?
    public dynamic var lastSubscriptionFetch: Date?

    // User
    public dynamic var userId: String?

    // Subscriptions
    public let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override public static func primaryKey() -> String? {
        return "serverURL"
    }
}

extension Auth {

    func baseURL() -> String? {
        if let cdn = self.settings?.cdnPrefixURL {
            if cdn.characters.count > 0 {
                return cdn
            }
        }

        return self.settings?.siteURL
    }

}
