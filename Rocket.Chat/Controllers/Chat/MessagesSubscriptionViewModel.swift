//
//  MessagesSubscriptionViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 26/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessagesSubscriptionViewModel {

    internal var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }
            subscribe(for: subscription)
        }
    }

    internal func subscribe(for subscription: Subscription) {
        MessageManager.changes(subscription)
        MessageManager.subscribeDeleteMessage(subscription)
    }

    internal func setTyping(value: Bool = false) {
        // TODO
    }

}
