//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

public typealias MessagesHistoryCompletion = (Date?) -> Void

struct MessageManager {
    static let historySize = 60
}

let kBlockedUsersIndentifiers = "kBlockedUsersIndentifiers"

extension MessageManager {

    static var blockedUsersList = UserDefaults.group.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []

    static func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping MessagesHistoryCompletion) {
        var lastDate: Any!

        if let lastMessageDate = lastMessageDate {
            lastDate = ["$date": lastMessageDate.timeIntervalSince1970 * 1000]
        } else {
            lastDate = NSNull()
        }

        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", lastDate, historySize]
        ] as [String: Any]

        var lastMessageDate: Date?

        let currentRealm = Realm.current
        SocketManager.send(request) { response in
            guard !response.isError() else {
                return Log.debug(response.result.string)
            }

            let list = response.result["result"]["messages"].array
            let subscriptionIdentifier = subscription.identifier

            currentRealm?.execute({ (realm) in
                guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ?? "") else { return }

                list?.forEach { object in
                    let mockNewMessage = Message()
                    mockNewMessage.map(object, realm: realm)

                    if let existingMessage = realm.object(ofType: Message.self, forPrimaryKey: object["identifier"].stringValue) {
                        if existingMessage.updatedAt?.timeIntervalSince1970 == mockNewMessage.updatedAt?.timeIntervalSince1970 {
                            return
                        }
                    }

                    let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.subscription = detachedSubscription
                    })

                    realm.add(message, update: true)
                    lastMessageDate = message.createdAt
                }
            }, completion: {
                completion(lastMessageDate)
            })
        }
    }

    static func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "id": eventName,
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else {
                return Log.debug(response.result.string)
            }

            let object = response.result["fields"]["args"][0]
            let subscriptionIdentifier = subscription.identifier

            currentRealm?.execute({ (realm) in
                guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ?? "") else { return }
                let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.subscription = detachedSubscription
                })

                message.temporary = false
                realm.add(message, update: true)
            })
        }
    }

    static func subscribeDeleteMessage(_ subscription: Subscription, completion: @escaping (_ msgId: String) -> Void) {
        let eventName = "\(subscription.rid)/deleteMessage"
        let request = [
            "msg": "sub",
            "name": "stream-notify-room",
            "id": eventName,
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            if let msgId = response.result["fields"]["args"][0]["_id"].string {
                Realm.executeOnMainThread(realm: currentRealm, { realm in
                    guard let message = realm.object(ofType: Message.self, forPrimaryKey: msgId) else { return }
                    realm.delete(message)
                    completion(msgId)
                })
            }
        }
    }

    static func report(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "reportMessage",
            "params": [messageIdentifier, "Message reported by user."]
        ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    static func react(_ message: Message, emoji: String, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "setReaction",
            "params": [emoji, messageIdentifier]
        ] as [String: Any]

        SocketManager.send(request, completion: completion)
    }

    static func blockMessagesFrom(_ user: User, completion: @escaping VoidCompletion) {
        guard let userIdentifier = user.identifier else { return }

        var blockedUsers: [String] = UserDefaults.group.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []
        blockedUsers.append(userIdentifier)
        UserDefaults.group.setValue(blockedUsers, forKey: kBlockedUsersIndentifiers)
        self.blockedUsersList = blockedUsers

        Realm.execute({ (realm) in
            let messages = realm.objects(Message.self).filter("user.identifier = '\(userIdentifier)'")

            for message in messages {
                message.userBlocked = true
            }

            realm.add(messages, update: true)
        }, completion: completion)
    }

}
