//
//  UserModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import Realm

extension User: ModelHandler {
    func add(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
        realm.add(self, update: true)

        guard let identifier = self.identifier else { return }
        if let subscription = realm.objects(Subscription.self).filter("otherUserId = %@", identifier).first {
            subscription.otherUserId = identifier
            subscription.privateOtherUserStatus = privateStatus
            realm.add(subscription, update: true)
        }
    }

    func update(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
        realm.add(self, update: true)

        guard let identifier = self.identifier else { return }
        if let subscription = realm.objects(Subscription.self).filter("otherUserId = %@", identifier).first {
            subscription.otherUserId = identifier
            realm.add(subscription, update: true)
        }
    }

    func remove(_ values: JSON, realm: Realm) {
        self.map(values, realm: realm)
        self.status = .offline
        realm.add(self, update: true)
    }
}
