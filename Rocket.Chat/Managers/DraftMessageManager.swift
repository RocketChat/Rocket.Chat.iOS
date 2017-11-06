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
    static var selectedServerKey: String {
        return DatabaseManager.servers?[DatabaseManager.selectedIndex][ServerPersistKeys.serverURL] ?? ""
    }

    static internal func draftMessageKey(for identifier: String) -> String {
        return String(format: "\(identifier)-cacheddraftmessage")
    }

    static func clearServerDraftMessages() {
        guard !selectedServerKey.isEmpty else { return }
        userDefaults.set(nil, forKey: selectedServerKey)
    }

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

    static func draftMessage(for subscription: Subscription) -> String {
        guard !selectedServerKey.isEmpty else { return "" }
        let subscriptionKey = draftMessageKey(for: subscription.rid)

        if let serverDraftMessages = userDefaults.dictionary(forKey: selectedServerKey),
            let draftMessage = serverDraftMessages[subscriptionKey] as? String {
            return draftMessage
        } else {
            return ""
        }
    }

}
