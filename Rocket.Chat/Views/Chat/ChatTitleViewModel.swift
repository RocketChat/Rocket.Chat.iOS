//
//  ChatTitleViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class ChatTitleViewModel {

    internal var user: User?
    var subscription: Subscription? {
        didSet {
            guard
                let subscription = subscription,
                !subscription.isInvalidated
            else {
                return
            }

            if let otherUser = subscription.directMessageUser {
                user = otherUser
            }
        }
    }

    var title: String? {
        return subscription?.displayName()
    }

    internal var iconColor: UIColor {
        guard let user = user else { return .RCGray() }

        switch user.status {
        case .online: return .RCOnline()
        case .offline: return .RCGray()
        case .away: return .RCAway()
        case .busy: return .RCBusy()
        }
    }

    var image: UIImage? {
        guard let subscription = subscription else { return nil }

        switch subscription.type {
        case .channel: return UIImage(named: "Hashtag")?.imageWithTint(iconColor)
        case .directMessage: return UIImage(named: "Mention")?.imageWithTint(iconColor)
        case .group: return UIImage(named: "Lock")?.imageWithTint(iconColor)
        }
    }

}
