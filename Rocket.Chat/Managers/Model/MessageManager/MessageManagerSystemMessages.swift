//
//  MessageManagerSystemMessages.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension MessageManager {

    static func createSystemMessage(from object: [String: JSON], realm: Realm? = Realm.current) {
        guard let realm = realm else { return }
        guard let subscriptionIdentifier = object["rid"]?.string else { return }

        realm.execute({ (realm) in
            guard let detachedSubscription = Subscription.find(rid: subscriptionIdentifier, realm: realm) else { return }

            let message = Message.getOrCreate(realm: realm, values: JSON(object), updates: { (object) in
                object?.rid = detachedSubscription.rid
            })

            if message.userIdentifier == nil {
                message.userIdentifier = "rocket.cat"
            }

            message.privateMessage = true
            realm.add(message, update: true)
        })
    }

}
