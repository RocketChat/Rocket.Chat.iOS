//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct MessageManager {
    static let historySize = 30
}

extension MessageManager {

    static func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping MessageCompletionObjectsList<Message>) {
        var lastDate: Any!

        if let lastMessageDate = lastMessageDate {
            lastDate = ["$date": lastMessageDate.timeIntervalSince1970 * 1000]
        } else {
            lastDate = NSNull()
        }

        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", lastDate, historySize, [
                "$date": Date().timeIntervalSince1970 * 1000
            ]]
        ] as [String : Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let messages = List<Message>()
            let list = response.result["result"]["messages"].array

            list?.forEach { object in
                let message = Message.getOrCreate(values: object, updates: { (object) in
                    object?.subscription = subscription
                })

                messages.append(message)
            }

            Realm.update(messages)
            completion(Array(messages))
        }
    }

    static func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "params": [eventName, false]
        ] as [String : Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][0]
            let message = Message.getOrCreate(values: object, updates: { (object) in
                object?.subscription = subscription
            })

            Realm.update(message)
        }
    }

    static func report(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "reportMessage",
            "params": [messageIdentifier, "Message reported by user."]
        ] as [String : Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

}
