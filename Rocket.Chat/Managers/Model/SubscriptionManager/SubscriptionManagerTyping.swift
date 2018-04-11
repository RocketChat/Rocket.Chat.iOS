//
//  SubscriptionManager+Typing.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SubscriptionManager {
    static func subscribeTypingEvent(_ subscription: Subscription, completion: @escaping (String?, Bool) -> Void) {
        let eventName = "\(subscription.rid)/typing"
        let request = [
            "msg": "sub",
            "name": "stream-notify-room",
            "id": eventName,
            "params": [eventName, false]
            ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let msg = response.result["fields"]["args"]
            let userNameTyping = msg[0].string
            let flag = (msg[1].int ?? 0) > 0

            completion(userNameTyping, flag)
        }
    }

    static func sendTypingStatus(_ subscription: Subscription, isTyping: Bool, completion: MessageCompletion? = nil) {
        guard let username = AuthManager.currentUser()?.username else { return }

        let request = [
            "msg": "method",
            "method": "stream-notify-room",
            "params": ["\(subscription.rid)/typing", username, isTyping]
            ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            completion?(response)
        }
    }
}
