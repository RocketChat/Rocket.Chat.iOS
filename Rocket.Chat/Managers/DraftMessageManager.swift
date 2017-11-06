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
    static var currentServerKey: String {
        return DatabaseManager.servers?[DatabaseManager.selectedIndex][ServerPersistKeys.serverURL] ?? ""
    }

    static internal func draftMessageKey(for identifier: String) -> String {
        return String(format: "\(identifier)-cacheddraftmessage")
    }

    static func clearServerDraftMessages() {
        guard !currentServerKey.isEmpty else { return }
        userDefaults.set(nil, forKey: currentServerKey)
    }

    static func update(draftMessage: String, for subscription: Subscription) {
        guard !currentServerKey.isEmpty else { return }
        let subscriptionKey = draftMessageKey(for: subscription.rid)

        if var currentServerDraftMessages = userDefaults.dictionary(forKey: currentServerKey) {
            currentServerDraftMessages[subscriptionKey] = draftMessage
            userDefaults.set(currentServerDraftMessages, forKey: currentServerKey)
        } else {
            userDefaults.set([subscriptionKey: draftMessage], forKey: currentServerKey)
        }
    }

    static func draftMessage(for subscription: Subscription) -> String {
        guard !currentServerKey.isEmpty else { return "" }
        let subscriptionKey = draftMessageKey(for: subscription.rid)

        if let subscriptionsDraftMessages = userDefaults.dictionary(forKey: currentServerKey),
                let draftMessage = subscriptionsDraftMessages[subscriptionKey] as? String {
            return draftMessage
        } else {
            return ""
        }
    }

}
