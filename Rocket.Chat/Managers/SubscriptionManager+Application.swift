//
//  SubscriptionManager+Application.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension SubscriptionManager {
    static func updateUnreadApplicationBadge() {
        var unread = 0

        Realm.execute({ (realm) in
            for obj in realm.objects(Subscription.self) {
                unread += obj.unread
            }
        }, completion: {
            UIApplication.shared.applicationIconBadgeNumber = unread
        })
    }
}
