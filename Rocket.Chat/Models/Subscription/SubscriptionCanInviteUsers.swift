//
//  SubscriptionCanInviteUsers.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {
    func canInviteUsers(user: User? = AuthManager.currentUser()) -> Bool {
        guard let user = user else {
            return false
        }

        if isJoined() && user.hasPermission(.addUserToJoinedRoom, subscription: self) {
            return true
        }

        if type == .channel && user.hasPermission(.addUserToAnyChannelRoom, subscription: self) {
            return true
        }

        if type == .group && user.hasPermission(.addUserToAnyPrivateRoom, subscription: self) {
            return true
        }

        return false
    }
}
