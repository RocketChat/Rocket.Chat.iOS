//
//  MessagesSubscriptionViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 26/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

public typealias TypingChangedBlock = ([String]) -> Void

final class MessagesSubscriptionViewModel {

    internal var subscription: UnmanagedSubscription? {
        didSet {
            if let subscription = subscription {
                subscribe(for: subscription)

                subscriptionQueryToken?.invalidate()
                subscriptionQueryToken = subscription.managedObject?.observe({ [weak self] _ in
                    self?.onDataChanged?()
                })
            }
        }
    }

    internal var subscriptionQueryToken: NotificationToken?
    internal var onDataChanged: VoidCompletion?
    internal var onTypingChanged: TypingChangedBlock?

    internal var usersTyping: [String] = []
    internal var isTyping: Bool = false {
        didSet {
            if oldValue == true && isTyping == false {
                sendTypingStatus()
            }

            throttledSendTypingStatus()
        }
    }

    internal lazy var throttledSendTypingStatus = throttle(1, action: sendTypingStatus)
    internal lazy var sendTypingStatus = { [weak self] in
        guard
            let self = self,
            let subscription = self.subscription?.managedObject
        else {
            return
        }

        SubscriptionManager.sendTypingStatus(subscription, isTyping: self.isTyping)
    }

    // MARK: Life Cycle

    deinit {
        destroy()
    }

    internal func destroy() {
        subscriptionQueryToken?.invalidate()

        if let subscription = subscription {
            unsubscribe(for: subscription)
        }
    }

    // MARK: Subscriptions Control

    /**
     This method enables all kind of updates related to the messages
     of the subscription attached to the view model.
     */
    internal func subscribe(for subscription: UnmanagedSubscription) {
        subscripeTypingEvent(for: subscription)
    }

    /**
     This method will remove all the subscriptions related to
     messages of the subscription attached to the view model.
     */
    internal func unsubscribe(for subscription: UnmanagedSubscription) {
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
    }

    /**
     This method subscribes to the typing event via WebSocket
     from a Subscription.
     */
    internal func subscripeTypingEvent(for subscription: UnmanagedSubscription) {
        guard let loggedUsername = AuthManager.currentUser()?.username else { return }

        SubscriptionManager.subscribeTypingEvent(subscription) { [weak self] username, flag in
            guard
                let self = self,
                let username = username,
                username != loggedUsername
            else {
                return
            }

            if flag && self.usersTyping.firstIndex(of: username) == nil {
                self.usersTyping.append(username)
            } else {
                if let index = self.usersTyping.firstIndex(of: username) {
                    self.usersTyping.remove(at: index)
                }
            }

            self.onTypingChanged?(self.usersTyping)
        }
    }

}
