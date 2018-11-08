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
        switch type {
        case .channel: fetchChannelIdentifier(completion)
        case .directMessage: fetchDirectMessageIdentifier(completion)
        default: break
        }
    }

    private func fetchChannelIdentifier(_ completion: @escaping MessageCompletionObject <Subscription>) {
        guard let identifier = self.identifier else { return }

        SubscriptionManager.getRoom(byName: name, completion: { (response) in
            guard !response.isError() else { return }
            guard let rid = response.result["result"]["_id"].string else { return }

            let result = response.result["result"]
            Realm.execute({ realm in
                if let obj = Subscription.find(withIdentifier: identifier) {
                    obj.rid = rid
                    obj.update(result, realm: realm)
                    realm.add(obj, update: true)
                }
            }, completion: {
                if let subscription = Subscription.find(rid: rid) {
                    completion(subscription)
                }
            })
        })
    }

    private func fetchDirectMessageIdentifier(_ completion: @escaping MessageCompletionObject <Subscription>) {
        guard let identifier = self.identifier else { return }

        SubscriptionManager.createDirectMessage(name, completion: { (response) in
            guard !response.isError() else { return }
            guard let rid = response.result["result"]["rid"].string else { return }

            Realm.execute({ realm in
                // We need to check for the existence of one Subscription
                // here because another real time response may have
                // already included this object into the database
                // before this block is executed.
                if let existingObject = Subscription.find(rid: rid, realm: realm) {
                    if let obj = Subscription.find(withIdentifier: identifier) {
                        realm.add(existingObject, update: true)
                        realm.delete(obj)
                    }
                } else {
                    if let obj = Subscription.find(withIdentifier: identifier) {
                        obj.rid = rid
                        realm.add(obj, update: true)
                    }
                }
            }, completion: {
                if let subscription = Subscription.find(rid: rid) {
                    completion(subscription)
                }
            })
        })
    }

    func fetchMessages(_ limit: Int = 20, lastMessageDate: Date? = nil) -> [Message] {
        var limitedMessages: [Message] = []

        guard var messages = fetchMessagesQueryResults() else { return [] }

        if let lastMessageDate = lastMessageDate {
            messages = messages.filter("createdAt < %@", lastMessageDate)
        }

        let totalMessagesIndexes = messages.count - 1
        for index in 0..<limit {
            let reversedIndex = totalMessagesIndexes - index

            guard totalMessagesIndexes >= reversedIndex, reversedIndex >= 0 else {
                return limitedMessages
            }

            limitedMessages.append(messages[reversedIndex])
        }

        return limitedMessages
    }

    func fetchMessagesQueryResults() -> Results<Message>? {
        guard var filteredMessages = self.messages?.filter("userBlocked == false AND identifier != NULL AND createdAt != NULL") else {
            return nil
        }

        if let hiddenTypes = AuthSettingsManager.settings?.hiddenTypes {
            for hiddenType in hiddenTypes {
                filteredMessages = filteredMessages.filter("internalType != %@", hiddenType.rawValue)
            }
        }

        return filteredMessages.sorted(byKeyPath: "createdAt", ascending: true)
    }

    func updateFavorite(_ favorite: Bool) {
        Realm.executeOnMainThread({ _ in
            self.favorite = favorite
        })
    }
}

// MARK: Failed Messages

extension Subscription {

    func setTemporaryMessagesFailed(user: User? = AuthManager.currentUser()) {
        guard let user = user else {
            return
        }

        Realm.executeOnMainThread { realm in
            self.messages?.filter("temporary = true").filter({
                $0.user == user
            }).forEach {
                $0.temporary = false
                $0.failed = true
                realm.add($0, update: true)
            }
        }
    }

}
