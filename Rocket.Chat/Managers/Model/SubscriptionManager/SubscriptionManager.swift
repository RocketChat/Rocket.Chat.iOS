//
//  SubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct SubscriptionManager {
    static func updateUnreadApplicationBadge() {
        var unread = 0

        Realm.execute({ _ in
            if let list = Subscription.all() {
                for obj in list {
                    unread += obj.unread
                }
            }
        }, completion: {
            UIApplication.shared.applicationIconBadgeNumber = unread
        })
    }

    static func updateSubscriptions(_ auth: Auth, realm: Realm? = Realm.current, completion: (() -> Void)?) {
        realm?.refresh()

        let validAuth = auth.validated() ?? AuthManager.isAuthenticated(realm: realm)
        guard let auth = validAuth else {
            return
        }

        let client = API.current(realm: realm)?.client(SubscriptionsClient.self)
        let lastUpdateSubscriptions = auth.lastSubscriptionFetchWithLastMessage?.addingTimeInterval(-100000)
        let lastUpdateRooms = auth.lastRoomFetchWithLastMessage?.addingTimeInterval(-100000)

        // The call needs to be nested because at the first time the user
        // opens the app we don't have the Subscriptions and the Room object
        // is not able to create one, so the request needs to be completed
        // only after the Subscriptions one is finished.
        client?.fetchSubscriptions(updatedSince: lastUpdateSubscriptions, realm: realm) {
            client?.fetchRooms(updatedSince: lastUpdateRooms, realm: realm) {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }

    static func changes(_ auth: Auth) {
        guard !auth.isInvalidated else { return }

        let serverURL = auth.serverURL

        let eventName = "\(auth.userId ?? "")/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let msg = response.result["fields"]["args"][0].stringValue
            let object = response.result["fields"]["args"][1]

            currentRealm?.execute({ (realm) in
                guard let auth = AuthManager.isAuthenticated(realm: realm), auth.serverURL == serverURL else { return }

                guard let rid = object["rid"].string, !rid.isEmpty else {
                    return
                }

                let subscription = Subscription.find(rid: rid, realm: realm) ??
                    Subscription.getOrCreate(realm: realm, values: object, updates: nil)
                subscription.map(object, realm: realm)

                if msg == "removed" {
                    realm.delete(subscription)
                } else {
                    subscription.auth = auth
                    realm.add(subscription, update: true)
                }
            })
        }
    }

    static func subscribeRoomChanges() {
        guard let user = AuthManager.currentUser() else { return }

        let eventName = "\(user.identifier ?? "")/rooms-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][1]

            currentRealm?.execute({ (realm) in
                if let rid = object["_id"].string {
                    if let subscription = Subscription.find(rid: rid, realm: realm) {
                        subscription.mapRoom(object, realm: realm)
                        realm.add(subscription, update: true)
                    }
                }
            })
        }
    }

    static func subscribeInAppNotifications() {
        guard let user = AuthManager.currentUser() else { return }

        let eventName = "\(user.identifier ?? "")/notification"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            if let data = try? response.result["fields"]["args"][0].rawData() {
                let notification = try? JSONDecoder().decode(ChatNotification.self, from: data)
                notification?.post()
            }
        }
    }

    static func updateJitsiTimeout(rid: String) {
        let request = [
            "msg": "method",
            "method": "jitsi:updateTimeout",
            "params": [rid]
        ] as [String: Any]

        SocketManager.send(request) { _ in }
    }
}
