//
//  SubscriptionQueries.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Subscription {
    static func find(rid: String, realm: Realm? = Realm.current) -> Subscription? {
        return realm?.objects(Subscription.self).filter("rid == '\(rid)'").first
    }

    static func find(name: String, subscriptionType: [SubscriptionType], realm: Realm? = Realm.current) -> Subscription? {
        let predicate = NSPredicate(
            format: "name == %@ && privateType IN %@",
            name, subscriptionType.map { $0.rawValue }
        )

        return realm?.objects(Subscription.self).filter(predicate).first
    }

    static func notificationSubscription(auth: Auth) -> Subscription? {
        guard let roomId = AppManager.initialRoomId else { return nil }
        return auth.subscriptions.filter("rid = %@", roomId).first
    }

    static func lastSeenSubscription(auth: Auth) -> Subscription? {
        return auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false).first
    }

    static func subscription(with name: String, auth: Auth) -> Subscription? {
        return auth.subscriptions.filter("name = %@", name).first
    }

    static func initialSubscription(auth: Auth? = AuthManager.isAuthenticated()) -> Subscription? {
        guard let auth = auth else { return nil }

        if let subscription = notificationSubscription(auth: auth) {
            AppManager.initialRoomId = nil
            return subscription
        }

        if !auth.internalFirstChannelOpened {
            if let firstChannel = auth.settings?.firstChannelAfterLogin, !firstChannel.isEmpty {
                return subscription(with: firstChannel, auth: auth)
            }
        }

        return lastSeenSubscription(auth: auth)
    }
}
