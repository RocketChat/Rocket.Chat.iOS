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

    static func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "id": eventName,
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        let subscriptionIdentifier = subscription.rid

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else {
                return Log.debug(response.result.string)
            }

            let object = response.result["fields"]["args"][0]

            currentRealm?.execute({ (realm) in
                guard let detachedSubscription = Subscription.find(rid: subscriptionIdentifier, realm: realm) else { return }
                let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.rid = detachedSubscription.rid
                })

                message.temporary = false
                realm.add(message, update: true)
            })
        }
    }

    static func subscribeSystemMessages() {
        guard let userIdentifier = AuthManager.currentUser()?.identifier else { return }

        let eventName = "\(userIdentifier)/message"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "id": eventName,
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else {
                return Log.debug(response.result.string)
            }

            if let object = response.result["fields"]["args"].array?.first?.dictionary {
                createSystemMessage(from: object, realm: currentRealm)
            }
        }
    }

    static func subscribeDeleteMessage(_ subscription: Subscription) {
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
                currentRealm?.execute({ realm in
                    guard let message = realm.object(ofType: Message.self, forPrimaryKey: msgId) else { return }
                    realm.delete(message)
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

}
