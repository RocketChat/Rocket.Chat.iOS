//
//  DraftMessageManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct DraftMessageManager {

    static let userDefaults = UserDefaults.standard

    /**
         This property gets the selected server's URL for us to use it as a identification
         to store and retrieve its subscriptions's draft messages. If the server URL
         wind up changing the clients will need to logout and add a new server, since we clear
         the cache when the user logouts, using the server URL will help us to avoid keeping invalid
         server draft messages stored.
     */
    static var selectedServerKey: String {
        return DatabaseManager.servers?[DatabaseManager.selectedIndex][ServerPersistKeys.serverURL] ?? ""
    }

    /**
         This method takes a subscription id and returns a more meaningful key
         for us to persist.

         - parameter identifier: The subscription id to update or retrieve a draft message.
     */
    static internal func draftMessageKey(for identifier: String) -> String {
        return String(format: "\(identifier)-cacheddraftmessage")
    }

    /**
         This method clears all the cached draft messages for the selected server if any.
     */
    static func clearServerDraftMessages() {
        guard !selectedServerKey.isEmpty else { return }
        userDefaults.set(nil, forKey: selectedServerKey)
    }

    /**
         This method takes a draft message and a subscription so it can update
         the subscription current draft message then when the user come back to
         this subscription in the app the draft message will be available for him.

         - parameter draftMessage: The new draft message to update.
         - parameter subscription: The subscription that is related to the draftMessage.
     */
    static func update(draftMessage: String, for subscription: Subscription) {
        guard !selectedServerKey.isEmpty else { return }
        let subscriptionKey = draftMessageKey(for: subscription.rid)

        if var currentServerDraftMessages = userDefaults.dictionary(forKey: selectedServerKey) {
            currentServerDraftMessages[subscriptionKey] = draftMessage
            userDefaults.set(currentServerDraftMessages, forKey: selectedServerKey)
        } else {
            userDefaults.set([subscriptionKey: draftMessage], forKey: selectedServerKey)
        }
    }

    /**
         This method takes a subscription and returns the current cached draft message
         that is related to it.

         - parameter subscription: The subscription we that we need the draft message.
     */
    static func draftMessage(for subscription: Subscription) -> String {
        guard !selectedServerKey.isEmpty else { return "" }
        let subscriptionKey = draftMessageKey(for: subscription.rid)

        if let serverDraftMessages = userDefaults.dictionary(forKey: selectedServerKey),
            let draftMessage = serverDraftMessages[subscriptionKey] as? String {
            return draftMessage
        }

        return ""
    }

}
