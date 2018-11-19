//
//  HeaderChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 19/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct HeaderChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return HeaderCell.identifier
    }

    let rid: String

    var subscription: UnmanagedSubscription? {
        return Subscription.find(rid: rid)?.unmanaged
    }

    var avatarURL: URL? {
        if let subscription = self.subscription {
            if let user = subscription.directMessageUser {
                return User.avatarURL(forUsername: user.username)
            } else {

            }
        }

        return nil
    }

    var title: String {
        return subscription?.name ?? ""
    }

    var descriptionText: String {
        return subscription?.name ?? ""
    }

    var differenceIdentifier: String {
        return rid
    }

    func isContentEqual(to source: HeaderChatItem) -> Bool {
        return rid == source.rid
    }
}
