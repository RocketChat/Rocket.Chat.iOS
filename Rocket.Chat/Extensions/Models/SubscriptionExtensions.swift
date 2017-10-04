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
    func sortedByLastMessageDate() -> [Subscription] {
        return self.sorted(by: { (aSubscription, bSubscription) -> Bool in
            guard let aDate = aSubscription.roomUpdatedAt else { return false }
            guard let bDate = bSubscription.roomUpdatedAt else { return true }
            return aDate > bDate
        })
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS[cd] %@", name)
    }
}

extension Results where Element == Subscription {
    func sortedByLastMessageDate() -> [Subscription] {
        return self.sorted(by: { (aSubscription, bSubscription) -> Bool in
            guard let aDate = aSubscription.roomUpdatedAt else { return false }
            guard let bDate = bSubscription.roomUpdatedAt else { return true }
            return aDate > bDate
        })
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS[cd] %@", name)
    }
}
