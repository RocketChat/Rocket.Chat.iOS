//
//  SubscriptionManager+Messages.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SubscriptionManager {
    static func markAsRead(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "readMessages",
            "params": [subscription.rid]
        ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    static func sendTextMessage(_ message: Message, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "sendMessage",
            "params": [[
                "_id": message.identifier ?? "",
                "rid": message.subscription?.rid ?? "",
                "msg": message.text
            ]]
        ] as [String: Any]

        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    static func toggleFavorite(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "toggleFavorite",
            "params": [subscription.rid, !subscription.favorite]
            ] as [String: Any]

        SocketManager.send(request, completion: completion)
    }
}
