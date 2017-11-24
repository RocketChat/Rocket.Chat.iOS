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

    var title: String {
        return subscription?.displayName() ?? ""
    }

    var iconColor: UIColor {
        guard let user = user else { return .RCGray() }

        switch user.status {
        case .online: return .RCOnline()
        case .offline: return .RCGray()
        case .away: return .RCAway()
        case .busy: return .RCBusy()
        }
    }

    var imageName: String {
        guard let subscription = subscription else {
            return "Hashtag"
        }

        switch subscription.type {
        case .channel: return "Hashtag"
        case .directMessage: return "Mention"
        case .group: return "Lock"
        }
    }

}
