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

// MARK: URL Generation

extension Subscription {

    /**
     This method returns the external URL of any subscription
     when all the information required is valid on the related instance.

     - returns: the external URL of the subscription object
     */
    func externalURL() -> URL? {
        guard
            let auth = auth,
            let siteURLString = auth.settings?.siteURL,
            name.count > 0
        else {
            return nil
        }

        let suffix: String = {
            switch type {
            case .channel: return "channel"
            case .directMessage: return "direct"
            case .group: return "group"
            }
        }()

        return URL(string: "\(siteURLString)/\(suffix)/\(name)")
    }

}

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

    static func all(onlyJoined: Bool = true, realm: Realm? = Realm.current) -> Results<Subscription>? {
        let results = realm?.objects(Subscription.self)
        return onlyJoined ? results?.filter("auth != NULL && open == TRUE") : results
    }

}

extension Results where Element == Subscription {

    func sortedByName() -> Results<Subscription> {
        let shouldUseRealName = AuthSettingsManager.settings?.useUserRealName ?? false
        return sorted(byKeyPath: shouldUseRealName ? "fname" : "name", ascending: true)
    }

    func sortedByLastMessageDate() -> Results<Subscription> {
        return sorted(byKeyPath: "roomLastMessageDate", ascending: false)
    }

    func sortedByLastSeen() -> Results<Subscription> {
        return sorted(byKeyPath: "lastSeen", ascending: false)
    }

    func sortedByRoomUpdatedAt() -> Results<Subscription> {
        return sorted(byKeyPath: "roomUpdatedAt", ascending: false)
    }

    func filterBy(name: String) -> Results<Subscription> {
        let userIdentifiersForDMs: [String] = Realm.current?.objects(User.self).filter(NSCompoundPredicate(
            type: .or,
            subpredicates: [
                NSPredicate(format: "name CONTAINS[cd] %@", name),
                NSPredicate(format: "username CONTAINS[cd] %@", name)
            ]
        )).compactMap({ $0.identifier }) ?? []

        return filter(NSCompoundPredicate(
            type: .or,
            subpredicates: [
                NSPredicate(format: "name CONTAINS[cd] %@", name),
                NSPredicate(format: "fname CONTAINS[cd] %@", name),
                NSPredicate(format: "otherUserId IN %@", userIdentifiersForDMs)
            ]
        ))
    }

}
