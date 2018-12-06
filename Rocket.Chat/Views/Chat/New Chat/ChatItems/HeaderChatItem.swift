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
    static let globalIdentifier = String(describing: HeaderChatItem.self)

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
                return Subscription.avatarURL(for: subscription.name)
            }
        }

        return nil
    }

    var title: String {
        return subscription?.displayName ?? ""
    }

    var descriptionText: String {
        guard let subscription = subscription else { return "" }

        if subscription.type == .directMessage {
            return String(format: localized("chat.dm.start_conversation"), subscription.displayName)
        }

        return String(format: localized("chat.channel.start_conversation"), subscription.displayName)
    }

    var differenceIdentifier: String {
        return HeaderChatItem.globalIdentifier
    }

    func isContentEqual(to source: HeaderChatItem) -> Bool {
        return differenceIdentifier == source.differenceIdentifier
    }
}
