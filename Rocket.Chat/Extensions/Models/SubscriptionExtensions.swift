//
//  SubscriptionExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: Information Viewing Options

extension Subscription {

    var canViewMembersList: Bool {
        guard let currentUser = AuthManager.currentUser() else { return false }

        if currentUser == roomOwner {
            return true
        }

        if currentUser.canViewAdminPanel() {
            return true
        }

        return !roomBroadcast
    }

    var canViewMentionsList: Bool {
        return type != .directMessage
    }

}

extension LinkingObjects where Element == Subscription {
    func sortedByLastSeen() -> Results<Subscription> {
        return self.sorted(byKeyPath: "lastSeen", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS[cd] %@", name)
    }
}

extension Results where Element == Subscription {
    func sortedByLastSeen() -> Results<Subscription> {
        return self.sorted(byKeyPath: "lastSeen", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        return self.filter("name CONTAINS[cd] %@", name)
    }
}
