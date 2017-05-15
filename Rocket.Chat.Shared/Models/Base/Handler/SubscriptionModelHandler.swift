//
//  SubscriptionModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Subscription: ModelHandler {
    func add(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
    }

    func update(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
    }

    func remove(_ values: JSON, realm: Realm) {
        realm.delete(self)
    }
}
