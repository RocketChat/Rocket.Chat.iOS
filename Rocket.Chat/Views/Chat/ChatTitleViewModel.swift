//
//  ChatTitleViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class ChatTitleViewModel {

    internal var user: UnmanagedUser?
    var subscription: UnmanagedSubscription? {
        didSet {
            guard let subscription = subscription else {
                return
            }

            user = subscription.directMessageUser
        }
    }

    var mainThreadMessage: UnmanagedMessage?

    var title: String {
        if let mainThreadMessage = mainThreadMessage {
            return mainThreadMessage.mainThreadTitle
        }

        return subscription?.displayName ?? ""
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
        if mainThreadMessage != nil {
            return "Threads"
        }

        guard let subscription = subscription else {
            return "Channel Small"
        }

        if subscription.isDiscussion {
            return "Discussions"
        }

        switch subscription.type {
        case .channel: return "Channel Small"
        case .directMessage: return "DM Small"
        case .group: return "Group Small"
        }
    }

}
