//
//  SubscriptionQueries.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Subscription {

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

}
