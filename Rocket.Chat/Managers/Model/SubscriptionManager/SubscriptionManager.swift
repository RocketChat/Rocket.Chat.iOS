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

        Realm.execute({ (realm) in
            for obj in realm.objects(Subscription.self) {
                unread += obj.unread
            }
        }, completion: {
            UIApplication.shared.applicationIconBadgeNumber = unread
        })
    }

    static func updateSubscriptions(_ auth: Auth, completion: (() -> Void)?) {
        let client = API.current()?.client(SubscriptionsClient.self)
        let lastUpdate = auth.lastSubscriptionFetchWithLastMessage

        client?.fetchSubscriptions(updatedSince: lastUpdate) {
            client?.fetchRooms(updatedSince: lastUpdate) {
                completion?()
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

            let msg = response.result["fields"]["args"][0]
            let object = response.result["fields"]["args"][1]

            currentRealm?.execute({ (realm) in
                guard let auth = AuthManager.isAuthenticated(realm: realm), auth.serverURL == serverURL else { return }
                let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.auth = msg == "removed" ? nil : auth
                })

                realm.add(subscription, update: true)
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
}
