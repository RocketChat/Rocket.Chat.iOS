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

let kBlockedUsersIndentifiers = "kBlockedUsersIndentifiers"

extension MessageManager {

    static var blockedUsersList = UserDefaults.standard.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []

    static func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping VoidCompletion) {
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
            let list = response.result["result"]["messages"].array

            let validMessages = List<Message>()
            let subscriptionIdentifier = subscription.identifier

            Realm.execute({ (realm) in
                guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ?? "") else { return }

                list?.forEach { object in
                    let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.subscription = detachedSubscription
                    })

                    realm.add(message, update: true)

                    if !message.userBlocked {
                        validMessages.append(message)
                    }
                }
            }, completion: completion)
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

            Realm.execute({ (realm) in
                let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.subscription = subscription
                })

                realm.add(message, update: true)
            })
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

    static func pin(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "pinMessage",
            "params": [ ["rid": message.rid, "_id": messageIdentifier ] ]
        ] as [String : Any]

        SocketManager.send(request, completion: completion)
    }

    static func unpin(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "unpinMessage",
            "params": [ ["rid": message.rid, "_id": messageIdentifier ] ]
        ] as [String : Any]

        SocketManager.send(request, completion: completion)
    }

    static func blockMessagesFrom(_ user: User, completion: @escaping VoidCompletion) {
        guard let userIdentifier = user.identifier else { return }

        var blockedUsers: [String] = UserDefaults.standard.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []
        blockedUsers.append(userIdentifier)
        UserDefaults.standard.setValue(blockedUsers, forKey: kBlockedUsersIndentifiers)
        self.blockedUsersList = blockedUsers

        Realm.execute({ (realm) in
            let messages = realm.objects(Message.self).filter("user.identifier = '\(userIdentifier)'")

            for message in messages {
                message.userBlocked = true
            }

            realm.add(messages, update: true)

            DispatchQueue.main.async {
                completion()
            }
        })
    }

}
