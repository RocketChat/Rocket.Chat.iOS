//
//  ChatControllerRolesController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension ChatViewController {
    func updateSubscriptionRoles() {
        guard
            let client = API.current()?.client(SubscriptionsClient.self),
            let subscription = subscription,
            subscription.type != .directMessage
        else {
            return
        }

        client.fetchRoles(subscription: subscription)
    }
}
