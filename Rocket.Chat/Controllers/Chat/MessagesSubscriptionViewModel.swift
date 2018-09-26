//
//  MessagesSubscriptionViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 26/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class MessagesSubscriptionViewModel {

    internal var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }
            subscribe(for: subscription)
            subscriptionQueryToken = subscription.observe({ [weak self] _ in
                self?.onDataChanged?()
            })
        }
    }

    internal var subscriptionQueryToken: NotificationToken?
    internal var onDataChanged: VoidCompletion?

    // MARK: Life Cycle

    deinit {
        subscriptionQueryToken?.invalidate()

        if let subscription = subscription?.validated() {
            unsubscribe(for: subscription)
        }
    }

    // MARK: Subscriptions Control

    /**
     This method enables all kind of updates related to the messages
     of the subscription attached to the view model.
     */
    internal func subscribe(for subscription: Subscription) {
        subscripeTypingEvent(for: subscription)
    }

    /**
     This method will remove all the subscriptions related to
     messages of the subscription attached to the view model.
     */
    internal func unsubscribe(for subscription: Subscription) {
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
    }

    internal func subscripeTypingEvent(for subscription: Subscription) {
        guard let loggedUsername = AuthManager.currentUser()?.username else { return }

        SubscriptionManager.subscribeTypingEvent(subscription) { [weak self] username, flag in
            guard let username = username, username != loggedUsername else { return }
            // TODO: Handle typing here.
        }
    }

}
