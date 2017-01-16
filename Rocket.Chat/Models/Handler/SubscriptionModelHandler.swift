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
    func add(_ values: JSON) {
        map(values)
    }

    func update(_ values: JSON) {
        map(values)
    }

    func remove(_ values: JSON) {
        Realm.delete(self)
    }
}
