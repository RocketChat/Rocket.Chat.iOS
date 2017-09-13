//
//  SubscriptionExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension LinkingObjects where Element == Subscription {
    func sortedByLastSeen() -> Results<Subscription> {
        return self.sorted(byKeyPath: "lastSeen", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS %@", name)
    }
}

extension Results where Element == Subscription {
    func sortedByLastSeen() -> Results<Subscription> {
        return self.sorted(byKeyPath: "lastSeen", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS %@", name)
    }
}
