//
//  SubscriptionManager+Messages.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SubscriptionManager {
    static func toggleFavorite(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "toggleFavorite",
            "params": [subscription.rid, !subscription.favorite]
            ] as [String: Any]

        SocketManager.send(request, completion: completion)
    }
}
