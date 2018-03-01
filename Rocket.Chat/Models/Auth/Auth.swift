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
    @objc dynamic var serverVersion = ""

    var apiHost: URL? {
        guard
            let socketURL = URL(string: serverURL, scheme: "https"),
            var components = URLComponents(url: socketURL, resolvingAgainstBaseURL: true)
        else {
            return nil
        }

        components.path = ""

        return components.url
    }

    @objc dynamic var settings: AuthSettings?

    // Token
    @objc dynamic var token: String?
    @objc dynamic var tokenExpires: Date?
    @objc dynamic var lastAccess: Date?
    @objc dynamic var lastSubscriptionFetch: Date?

    @objc dynamic var userId: String?

    // Subscriptions
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }
}
