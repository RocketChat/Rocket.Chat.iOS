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

    // User
    @objc dynamic var userId: String?

    var user: User? {
        guard let userId = userId else { return nil }

        let realm = self.realm ?? Realm.shared
        return realm?.object(ofType: User.self, forPrimaryKey: userId)
    }

    // Subscriptions
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "auth")

    // Primary key from Auth 
    override static func primaryKey() -> String? {
        return "serverURL"
    }
}

extension Auth {
    enum CanDeleteMessageResult {
        case allowed
        case timeElapsed
        case differentUser
        case serverBlocked
        case notActionable
        case unknown
    }

    func canDeleteMessage(_ message: Message) -> CanDeleteMessageResult {
        guard
            let createdAt = message.createdAt,
            let user = user,
            let settings = settings
        else {
            return .unknown
        }

        if !message.type.actionable {
            return .notActionable
        }

        if user.hasPermission(.forceDeleteMessage, realm: self.realm) {
            return .allowed
        }

        func timeElapsed() -> Bool {
            if settings.messageAllowDeletingBlockDeleteInMinutes < 1 {
                return false
            }

            return Date.serverDate.timeIntervalSince(createdAt)/60 > Double(settings.messageAllowDeletingBlockDeleteInMinutes)
        }

        if user.hasPermission(.deleteMessage, realm: self.realm) {
            return timeElapsed() ? .timeElapsed : .allowed
        }

        if message.user != user { return .differentUser }
        if !settings.messageAllowDeleting { return .serverBlocked }

        if timeElapsed() { return .timeElapsed }

        return .allowed
    }
}

extension Auth {
    enum CanEditMessageResult {
        case allowed
        case timeElapsed
        case differentUser
        case serverBlocked
        case notActionable
        case unknown
    }

    func canEditMessage(_ message: Message) -> CanEditMessageResult {
        guard
            let createdAt = message.createdAt,
            let user = user,
            let settings = settings
        else {
            return .unknown
        }

        if !message.type.actionable {
            return .notActionable
        }

        if user.hasPermission(.editMessage, realm: self.realm) {
            return .allowed
        }

        func timeElapsed() -> Bool {
            if settings.messageAllowEditingBlockEditInMinutes < 1 {
                return false
            }

            return Date.serverDate.timeIntervalSince(createdAt)/60 > Double(settings.messageAllowDeletingBlockDeleteInMinutes)
        }

        if message.user != user { return .differentUser }
        if !settings.messageAllowEditing { return .serverBlocked }

        if timeElapsed() { return .timeElapsed }

        return .allowed
    }
}

extension Auth {
    enum CanBlockMessageResult {
        case allowed
        case notActionable
        case myOwn
        case unknown
    }

    func canBlockMessage(_ message: Message) -> CanBlockMessageResult {
        guard let user = user else { return .unknown }

        if !message.type.actionable {
            return .notActionable
        }
        if message.user == user {
            return .myOwn
        }

        return .allowed
    }
}
