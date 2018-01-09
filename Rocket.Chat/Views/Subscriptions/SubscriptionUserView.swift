//
//  SubscriptionUserView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionUserView: UIView {
    override var accessibilityIdentifier: String? {
        get { return "subscriptions.main.userview" }
        set { }
    }

    override var accessibilityLabel: String? {
        get { return localizedAccessibilityLabel }
        set { }
    }

    override var accessibilityValue: String? {
        get {
            guard
                let user = AuthManager.currentUser(),
                let serverName = AuthManager.isAuthenticated()?.settings?.serverName,
                let format = VOLocalizedString("subscriptions.main.userview.value")
            else {
                return nil
            }

            return String(format: format, serverName, user.displayName(), user.status.rawValue)
        }
        set { }
    }

    override var accessibilityHint: String? {
        get { return localizedAccessibilityHint }
        set { }
    }
}
