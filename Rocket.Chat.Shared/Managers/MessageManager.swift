//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

/// A manager that manages all message related actions
public class MessageManager: SocketManagerInjected {
    /// Default history fetch size
    let initialHistorySize = 30
    let laterHistorySize = 50

    /// A list that maintains all blocked users, stored in `UserDefaults`
    var blockedUsersList = UserDefaults.standard.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []
}

/// The key that refer to blocked users list in `UserDefaults`
let kBlockedUsersIndentifiers = "kBlockedUsersIndentifiers"

extension MessageManager {

    /// Get history messages of the target subscription and store locally
    ///
    /// - Parameters:
    ///   - subscription: the target subscription
    ///   - lastMessageDate: a date that indicates a criteria of the query
    ///   - completion: will be called after action completion
    public func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping MessageCompletionObjectsList<Message>) {
        var lastDate: Any!
        var size: Int

        if let lastMessageDate = lastMessageDate {
            lastDate = ["$date": lastMessageDate.timeIntervalSince1970 * 1000]
            size = laterHistorySize
        } else {
            lastDate = NSNull()
            size = initialHistorySize
        }

        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", lastDate, size, [
                "$date": Date().timeIntervalSince1970 * 1000
            ]]
        ] as [String : Any]

        let validMessages = List<Message>()

        socketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            let list = response.result["result"]["messages"].array

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
                    } else {
                        // TODO: Dependency Injection in model mapping
                        guard let user = message.user else { return }
                        guard let uid = user.identifier else { return }
                        if !self.blockedUsersList.contains(uid) {
                            validMessages.append(message)
                        }
                    }
                }
            }, completion: {
                completion(Array(validMessages))
            })
        }
    }

    /// Subscribe the changes of the target subscription
    ///
    /// - Parameter subscription: target subscription
    public func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "params": [eventName, false]
        ] as [String : Any]

        socketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][0]
            let subscriptionIdentifier = subscription.identifier

            Realm.execute({ (realm) in
                guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ?? "") else { return }
                let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.subscription = detachedSubscription
                })

                realm.add(message, update: true)
            })
        }
    }

    func report(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "reportMessage",
            "params": [messageIdentifier, "Message reported by user."]
        ] as [String : Any]

        socketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    /// Pin a given message
    ///
    /// - Parameters:
    ///   - message: the message to be pinned
    ///   - completion: will be called after action completion
    public func pin(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "pinMessage",
            "params": [ ["rid": message.rid, "_id": messageIdentifier ] ]
        ] as [String : Any]

        socketManager.send(request, completion: completion)
    }

    /// Unpin a given message
    ///
    /// - Parameters:
    ///   - message: the message to be unpinned
    ///   - completion: will be called after action completion
    public func unpin(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "unpinMessage",
            "params": [ ["rid": message.rid, "_id": messageIdentifier ] ]
        ] as [String : Any]

        socketManager.send(request, completion: completion)
    }

    /// Block a user and all messages from him/her/them
    ///
    /// - Parameters:
    ///   - user: target user
    ///   - completion: will be called after action completion
   public func blockMessagesFrom(_ user: User, completion: @escaping VoidCompletion) {
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
