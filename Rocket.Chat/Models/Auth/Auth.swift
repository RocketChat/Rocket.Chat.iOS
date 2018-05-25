//
//  Auth.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class Auth: Object {
    // Server
    @objc dynamic var serverURL = ""
    @objc dynamic var serverVersion = ""

    var apiHost: URL? {
        guard let socketURL = URL(string: serverURL, scheme: "https") else {
            return nil
        }

        return socketURL.httpServerURL()
    }

    @objc dynamic var settings: AuthSettings?

    @objc dynamic var token: String?
    @objc dynamic var tokenExpires: Date?
    @objc dynamic var lastAccess: Date?
    @objc dynamic var lastSubscriptionFetchWithLastMessage: Date?

    @objc dynamic var userId: String?

    // Subscriptions
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }

    // MARK: Internal

    // This key controls if the first channel (based on firstChannelAfterLogin) setting
    // was already opened on this authentication object
    @objc dynamic var internalFirstChannelOpened = true
}
