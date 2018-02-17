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

    func sendMessage(text: String, subscription: Subscription, id: String = String.random(18), user: User? = AuthManager.currentUser(), realm: Realm? = Realm.shared) {
        let message = Message()
        message.internalType = ""
        message.updatedAt = nil
        message.createdAt = Date.serverDate
        message.text = text
        message.subscription = subscription
        message.user = user
        message.identifier = id
        message.temporary = true

        try? realm?.write {
            realm?.add(message)
        }

        func updateMessage(json: JSON) {
            DispatchQueue.main.async {
                try? realm?.write {
                    message.temporary = false
                    message.updatedAt = Date()
                    message.map(json, realm: realm)
                    realm?.add(message, update: true)
                }

                MessageTextCacheManager.shared.update(for: message)
            }
        }

        api.fetch(SendMessageRequest(id: id, roomId: subscription.rid, text: text), succeeded: { result in
            guard let message = result.raw?["message"] else { return }
            updateMessage(json: message)
        }, errored: { error in
            switch error {
            case .version:
                // TODO: Remove SendMessage Fallback + old methods after Rocket.Chat 1.0
                SubscriptionManager.sendTextMessage(message, completion: { response in
                    updateMessage(json: response.result["result"])
                })
            default:
                Alert.defaultError.present()
            }
        })
    }

    @discardableResult
    func deleteMessage(_ message: Message, asUser: Bool, realm: Realm? = Realm.shared) -> Bool {
        guard
            let id = message.identifier,
            !message.rid.isEmpty
        else {
            return false
        }

        api.fetch(DeleteMessageRequest(roomId: message.rid, msgId: id, asUser: asUser),
                  succeeded: nil, errored: { _ in Alert.defaultError.present() })

        return true
    }

    @discardableResult
    func updateMessage(_ message: Message, text: String, realm: Realm? = Realm.shared) -> Bool {
        guard
            let id = message.identifier,
            !message.rid.isEmpty
        else {
            return false
        }

        let request = UpdateMessageRequest(roomId: message.rid, msgId: id, text: text)

        api.fetch(request, succeeded: { response in
            guard let message = response.message else {
                return Alert.defaultError.present()
            }

            DispatchQueue.main.async {
                try? realm?.write {
                    realm?.add(message, update: true)
                }

                MessageTextCacheManager.shared.update(for: message)
            }

        }, errored: { _ in Alert.defaultError.present() })

        return true
    }
}
