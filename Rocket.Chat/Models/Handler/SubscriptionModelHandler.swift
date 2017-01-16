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

class SubscriptionModelHandler: BaseModelHandler {
    typealias Model = Subscription

    func add(_ object: Subscription, values: JSON) {
        object.update(values)
    }

    func update(_ object: Subscription, values: JSON) {
        object.update(values)
    }

    func remove(_ object: Subscription, values: JSON) {
        Realm.delete(object)
    }
}
