//
//  SubscriptionExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

typealias SortDescriptor<Value> = (Value, Value) -> Bool

// MARK: Information Viewing Options

extension Subscription {

    var canViewMembersList: Bool {
        if !roomBroadcast {
            return true
        }

        guard let currentUser = AuthManager.currentUser() else {
            return false
        }

        if currentUser == roomOwner {
            return true
        }

        if currentUser.canViewAdminPanel() {
            return true
        }

        if let currentUserRoles = usersRoles.filter({ $0.user?.identifier == currentUser.identifier }).first?.roles {
            if currentUserRoles.contains(Role.admin.rawValue) { return true }
            if currentUserRoles.contains(Role.moderator.rawValue) { return true }
            if currentUserRoles.contains(Role.owner.rawValue) { return true }
        }

        return false
    }

    var canViewMentionsList: Bool {
        return type != .directMessage
    }

}

extension Subscription {

    static func all() -> Results<Subscription>? {
        return Realm.current?.objects(Subscription.self).filter("auth != NULL")
    }

}

extension Results where Element == Subscription {

    func sortedByName() -> Results<Subscription> {
        return sorted(byKeyPath: "name", ascending: true)
    }

    func sortedByLastMessageDate() -> Results<Subscription> {
        return sorted(byKeyPath: "roomLastMessageDate", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        return filter("name CONTAINS[cd] %@", name)
    }

}
