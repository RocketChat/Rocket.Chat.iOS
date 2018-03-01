//
//  Subscription+Extensions.swift
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
            return settings.allowSpecialCharsOnRoomNames && fname != "" ? fname : name
        }

        return settings.useUserRealName ? fname : name
    }

    func isValid() -> Bool {
        return self.rid.count > 0
    }

    func isJoined() -> Bool {
        return auth != nil || type != .channel
    }

    func fetchRoomIdentifier(_ completion: @escaping MessageCompletionObject <Subscription>) {
        if type == .channel {
            SubscriptionManager.getRoom(byName: name, completion: { [weak self] (response) in
                guard !response.isError() else { return }

                let result = response.result["result"]
                Realm.executeOnMainThread({ realm in
                    if let obj = self {
                        obj.update(result, realm: realm)
                        realm.add(obj, update: true)
                    }
                })

                guard let strongSelf = self else { return }
                completion(strongSelf)
            })
        } else if type == .directMessage {
            SubscriptionManager.createDirectMessage(name, completion: { [weak self] (response) in
                guard !response.isError() else { return }

                let rid = response.result["result"]["rid"].stringValue
                Realm.executeOnMainThread({ realm in
                    if let obj = self {
                        obj.rid = rid
                        realm.add(obj, update: true)
                    }
                })

                guard let strongSelf = self else { return }
                completion(strongSelf)
            })
        }
    }

    func fetchMessages(_ limit: Int = 20, lastMessageDate: Date? = nil) -> [Message] {
        var limitedMessages: [Message] = []
        var messages = fetchMessagesQueryResults()

        if let lastMessageDate = lastMessageDate {
            messages = messages.filter("createdAt < %@", lastMessageDate)
        }

        for i in 0..<min(limit, messages.count) {
            limitedMessages.append(messages[i])
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
