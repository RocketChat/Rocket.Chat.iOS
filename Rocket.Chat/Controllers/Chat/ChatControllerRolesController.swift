//
//  ChatControllerRolesController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension ChatViewController {

    func updateSubscriptionRoles() {
        guard
            let subscription = subscription,
            subscription.type != .directMessage
        else {
            return
        }

        let rid = subscription.rid
        let rolesRequest = RoomRolesRequest(roomName: subscription.name, subscriptionType: subscription.type)
        API.current()?.fetch(rolesRequest, completion: { result in
            switch result {
            case .resource(let resource):
                if let subscription = Subscription.find(rid: rid) {
                    Realm.executeOnMainThread({ (realm) in
                        subscription.usersRoles.removeAll()
                        resource.subscriptionRoles?.forEach({ (role) in
                            subscription.usersRoles.append(role)
                        })

                        realm.add(subscription, update: true)
                    })
                }

            // Fail silently
            default: break
            }
        })
    }

}
