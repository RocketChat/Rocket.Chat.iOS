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

    // swiftlint:disable function_body_length
    func sendMessage(
        _ message: Message,
        subscription: UnmanagedSubscription,
        realm: Realm? = Realm.current,
        threadIdentifier: String? = nil
    ) {
        guard let id = message.identifier else { return }

        let subscriptionIdentifier = subscription.rid

        Realm.executeOnMainThread(realm: realm) { (realm) in
            if let subscriptionMutable = Subscription.find(rid: subscriptionIdentifier, realm: realm) {
                subscriptionMutable.roomLastMessage = message
                subscriptionMutable.roomLastMessageDate = message.createdAt
                subscriptionMutable.roomLastMessageText = Subscription.lastMessageText(lastMessage: message)
                realm.add(subscriptionMutable, update: true)
            }

            realm.add(message, update: true)
        }

        func updateMessage(json: JSON) {
            if message.validated() == nil {
                return
            }

            let server = AuthManager.selectedServerHost()

            AnalyticsManager.log(event: .messageSent(subscriptionType: subscription.type.rawValue, server: server))

            Realm.executeOnMainThread(realm: realm) { (realm) in
                message.temporary = false
                message.failed = false
                message.updatedAt = Date()
                message.map(json, realm: realm)
                realm.add(message, update: true)
            }

            if let unmanagedMessage = message.unmanaged {
                MessageTextCacheManager.shared.update(for: unmanagedMessage)
            }
        }

        func setMessageOffline() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if message.validated() == nil {
                    return
                }

                Realm.executeOnMainThread(realm: realm) { (realm) in
                    message.temporary = false
                    message.failed = true
                    message.updatedAt = Date()
                    realm.add(message, update: true)
                }

                if let unmanagedMessage = message.unmanaged {
                    MessageTextCacheManager.shared.update(for: unmanagedMessage)
                }
            }
        }

        let request = SendMessageRequest(
            id: id,
            roomId: subscription.rid,
            text: message.text,
            threadIdentifier: threadIdentifier?.isEmpty ?? true ? nil : threadIdentifier,
            messageType: message.internalType.isEmpty ? nil : message.internalType
        )

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                guard let message = resource.raw?["message"] else { return }
                updateMessage(json: message)
            case .error:
                setMessageOffline()
            }

        }
    }

    func sendMessage(
        text: String,
        internalType: String? = nil,
        subscription: UnmanagedSubscription,
        threadIdentifier: String? = nil,
        id: String = String.random(18),
        user: User? = AuthManager.currentUser(),
        realm: Realm? = Realm.current
    ) {
        let message = Message()
        message.internalType = internalType ?? ""
        message.updatedAt = nil
        message.createdAt = Date.serverDate
        message.text = text
        message.rid = subscription.rid
        message.userIdentifier = user?.identifier
        message.identifier = id
        message.temporary = true
        message.threadMessageId = threadIdentifier ?? ""

        sendMessage(message, subscription: subscription, realm: realm, threadIdentifier: threadIdentifier)
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
            case .resource(let resource):
                guard let resourceMessage = resource.message else {
                    return Alert.defaultError.present()
                }

                let shouldKeepMessageLocally = AuthManager.isAuthenticated()?.settings?.messageShowDeletedStatus ?? true
                if !shouldKeepMessageLocally {
                    Realm.executeOnMainThread(realm: realm) { realm in
                        realm.delete(message)
                    }
                } else {
                    // FA NOTE: Forcing deleted status since the API doesn't returns
                    // the internalType field after deleting a message
                    Realm.executeOnMainThread({ realm in
                        message.internalType = "rm"
                        realm.add(message, update: true)
                    })
                }

                if let unmanagedMessage = resourceMessage.unmanaged {
                    MessageTextCacheManager.shared.update(for: unmanagedMessage)
                }
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

        // optimistic UI update

        let message = Message(value: message)
        Realm.executeOnMainThread(realm: realm) { realm in
            message.updatedAt = Date()
            message.temporary = true
            message.text = text
            realm.add(message, update: true)
        }

        // send request

        let request = UpdateMessageRequest(roomId: message.rid, msgId: id, text: text)

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                guard let message = resource.message else {
                    return Alert.defaultError.present()
                }

                Realm.executeOnMainThread(realm: realm) { realm in
                    realm.add(message, update: true)
                }

                if let unmanagedMessage = message.unmanaged {
                    MessageTextCacheManager.shared.update(for: unmanagedMessage)
                }
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

        Realm.executeOnMainThread(realm: realm) { realm in
            realm.add(message, update: true)
        }

        api.fetch(ReactMessageRequest(msgId: id, emoji: emoji)) { response in
            switch response {
            case .resource:
                AnalyticsManager.log(
                    event: .reaction(
                        subscriptionType: message.subscription?.type.rawValue ?? ""
                    )
                )
            case .error:
                Alert.defaultError.present()
            }
        }

        return true
    }

    // swiftlint:enable function_body_length
}
