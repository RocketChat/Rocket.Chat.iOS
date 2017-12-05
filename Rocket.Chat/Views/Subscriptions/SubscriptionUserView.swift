//
//  SubscriptionUserView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionUserView: UIView {
    override var accessibilityLabel: String? {
        get { return "Session information" } set { }
    }

    override var accessibilityValue: String? {
        get {
            let user = AuthManager.currentUser()
            let serverName = AuthManager.isAuthenticated()?.settings?.serverName
            return """
                Server: \(serverName ?? "unknown").
                User: \(user?.name ?? "unknown")
                Status: \(user?.status.rawValue ?? "unknown")
            """
        } set { }
    }

    override var accessibilityHint: String? {
        get { return "Double tap to change status" } set { }
    }
}
