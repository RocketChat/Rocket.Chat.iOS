//
//  SubscriptionUtils.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Subscription {
    func displayName() -> String {
        guard let settings = AuthSettingsManager.settings else {
            return name
        }

        if type != .directMessage {
            return settings.allowSpecialCharsOnRoomNames && !fname.isEmpty ? fname : name
        }

        return settings.useUserRealName && !fname.isEmpty ? fname : name
    }

    func isValid() -> Bool {
        return self.rid.count > 0
    }

    func isJoined() -> Bool {
        return auth != nil || type != .channel
    }

    func fetchRoomIdentifier(_ completion: @escaping MessageCompletionObject <Subscription>) {
        guard let identifier = self.identifier else { return }

        if type == .channel {
            SubscriptionManager.getRoom(byName: name, completion: { (response) in
                guard !response.isError() else { return }

                let result = response.result["result"]
                Realm.execute({ realm in
                    if let obj = Subscription.find(withIdentifier: identifier) {
                        if let rid = response.result["result"]["_id"].string {
                            obj.rid = rid
                        }

                        obj.update(result, realm: realm)
                        realm.add(obj, update: true)
                    }
                }, completion: {
                    if let subscription = Subscription.find(withIdentifier: identifier) {
                        completion(subscription)
                    }
                })
            })
        } else if type == .directMessage {
            SubscriptionManager.createDirectMessage(name, completion: { (response) in
                guard !response.isError() else { return }

                let rid = response.result["result"]["rid"].stringValue
                Realm.execute({ realm in
                    if let obj = Subscription.find(withIdentifier: identifier) {
                        obj.rid = rid
                        realm.add(obj, update: true)
                    }
                }, completion: {
                    if let subscription = Subscription.find(withIdentifier: identifier) {
                        completion(subscription)
                    }
                })
            })
        }
    }

    func fetchMessages(_ limit: Int = 20, lastMessageDate: Date? = nil) -> [Message] {
        var limitedMessages: [Message] = []
        var messages = fetchMessagesQueryResults()

        if let lastMessageDate = lastMessageDate {
            messages = messages.filter("createdAt < %@", lastMessageDate)
        }

        for index in 0..<min(limit, messages.count) {
            limitedMessages.append(messages[index])
        }

        return limitedMessages
    }

    func fetchMessagesQueryResults() -> Results<Message> {
        var filteredMessages = self.messages.filter("userBlocked == false")

        if let hiddenTypes = AuthSettingsManager.settings?.hiddenTypes {
            for hiddenType in hiddenTypes {
                filteredMessages = filteredMessages.filter("internalType != %@", hiddenType.rawValue)
            }
        }

        return filteredMessages.sorted(byKeyPath: "createdAt", ascending: false)
    }

    func updateFavorite(_ favorite: Bool) {
        Realm.executeOnMainThread({ _ in
            self.favorite = favorite
        })
    }
}
