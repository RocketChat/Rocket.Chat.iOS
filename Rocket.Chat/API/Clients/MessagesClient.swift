//
//  MessagesClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SwiftyJSON

struct MessagesClient: APIClient {
    let api: AnyAPIFetcher

    func sendMessage(_ message: Message, subscription: Subscription, realm: Realm? = Realm.current) {
        guard let id = message.identifier else { return }

        try? realm?.write {
            realm?.add(message, update: true)
        }

        func updateMessage(json: JSON) {
            try? realm?.write {
                message.temporary = false
                message.failed = false
                message.updatedAt = Date()
                message.map(json, realm: realm)
                realm?.add(message, update: true)
            }

            MessageTextCacheManager.shared.update(for: message)
        }

        func setMessageOffline() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                try? realm?.write {
                    message.temporary = false
                    message.failed = true
                    message.updatedAt = Date()
                    realm?.add(message, update: true)
                }

                MessageTextCacheManager.shared.update(for: message)
            }
        }

        let request = SendMessageRequest(
            id: id,
            roomId: subscription.rid,
            text: message.text
        )

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                guard let message = resource.raw?["message"] else { return }
                updateMessage(json: message)
            case .error(let error):
                switch error {
                case .version:
                    SubscriptionManager.sendTextMessage(message, completion: { response in
                        updateMessage(json: response.result["result"])
                    })
                default:
                    setMessageOffline()
                }
            }

        }
    }

    func sendMessage(text: String, subscription: Subscription, id: String = String.random(18), user: User? = AuthManager.currentUser(), realm: Realm? = Realm.current) {
        let message = Message()
        message.internalType = ""
        message.updatedAt = nil
        message.createdAt = Date.serverDate
        message.text = text
        message.subscription = subscription
        message.user = user
        message.identifier = id
        message.temporary = true

        sendMessage(message, subscription: subscription, realm: realm)
    }

    @discardableResult
    func deleteMessage(_ message: Message, asUser: Bool, realm: Realm? = Realm.current) -> Bool {
        guard
            let id = message.identifier,
            !message.rid.isEmpty
        else {
            return false
        }

        api.fetch(DeleteMessageRequest(roomId: message.rid, msgId: id, asUser: asUser)) { response in
            switch response {
            case .resource: break
            case .error: Alert.defaultError.present()
            }
        }

        return true
    }

    @discardableResult
    func starMessage(_ message: Message, star: Bool) -> Bool {
        guard
            let id = message.identifier,
            !message.rid.isEmpty
        else {
            return false
        }

        api.fetch(StarMessageRequest(msgId: id, star: star)) { response in
            switch response {
            case .resource: break
            case .error: Alert.defaultError.present()
            }
        }

        return true
    }

    @discardableResult
    func pinMessage(_ message: Message, pin: Bool) -> Bool {
        guard
            let id = message.identifier,
            !message.rid.isEmpty
        else {
            return false
        }

        api.fetch(PinMessageRequest(msgId: id, pin: pin)) { response in
            switch response {
            case .resource: break
            case .error: Alert.defaultError.present()
            }
        }

        return true
    }

    @discardableResult
    func updateMessage(_ message: Message, text: String, realm: Realm? = Realm.current) -> Bool {
        guard let id = message.identifier, !message.rid.isEmpty else {
            return false
        }

        let request = UpdateMessageRequest(roomId: message.rid, msgId: id, text: text)

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                guard let message = resource.message else {
                    return Alert.defaultError.present()
                }

                try? realm?.write {
                    realm?.add(message, update: true)
                }

                MessageTextCacheManager.shared.update(for: message)
            case .error: Alert.defaultError.present()
            }
        }

        return true
    }

    @discardableResult
    func reactMessage(_ message: Message, emoji: String, user: User? = AuthManager.currentUser(), realm: Realm? = Realm.current) -> Bool {
        guard let id = message.identifier, let username = user?.username else {
            return false
        }

        let emoji = (emoji.first, emoji.last) == (":", ":") ? emoji : ":\(emoji):"
        let reactions = List(message.reactions)
        let message = Message(value: message)
        message.reactions = reactions

        if let reactionIndex = reactions.index(where: { $0.emoji == emoji }) {
            let reaction = MessageReaction(value: reactions[reactionIndex])
            if let usernameIndex = reaction.usernames.index(of: username) {
                let usernames = List(reaction.usernames)
                usernames.remove(at: usernameIndex)
                reaction.usernames = usernames
                if usernames.isEmpty {
                    reactions.remove(at: reactionIndex)
                } else {
                    reactions[reactionIndex] = reaction
                }
            } else {
                let usernames = List(reaction.usernames)
                usernames.append(username)
                reaction.usernames = usernames
                reactions[reactionIndex] = reaction
            }
        } else {
            let reaction = MessageReaction()
            reaction.usernames.append(username)
            reaction.emoji = emoji
            reactions.append(reaction)
        }

        message.reactions = reactions
        message.updatedAt = Date()

        try? realm?.write {
            realm?.add(message, update: true)
        }

        api.fetch(ReactMessageRequest(msgId: id, emoji: emoji)) { response in
            switch response {
            case .resource: break
            case .error(let error):
                switch error {
                case .version:
                    // version fallback
                    MessageManager.react(message, emoji: emoji, completion: { _ in })
                default:
                    Alert.defaultError.present()
                }
            }
        }

        return true
    }
}
