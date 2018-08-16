//
//  SubscriptionActions.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/16/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Subscription {
    func favoriteSubscription() {
        SubscriptionManager.toggleFavorite(self) { (response) in
            DispatchQueue.main.async {
                if response.isError() {
                    self.updateFavorite(!self.favorite)
                }
            }
        }

        self.updateFavorite(!self.favorite)
    }

    func hideSubscription() {
        let hideRequest = SubscriptionHideRequest(rid: self.rid, subscriptionType: self.type)
        API.current()?.fetch(hideRequest, completion: nil)

        Realm.executeOnMainThread { realm in
            realm.delete(self)
        }
    }

    func markRead() {
        API.current()?.fetch(SubscriptionReadRequest(rid: self.rid), completion: nil)
        Realm.executeOnMainThread { _ in
            self.alert = false
        }
    }

    func markUnread() {
        API.current()?.fetch(SubscriptionUnreadRequest(rid: self.rid), completion: nil)
        Realm.executeOnMainThread { _ in
            self.alert = true
        }
    }
}
