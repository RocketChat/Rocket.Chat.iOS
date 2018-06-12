//
//  StatusViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 23/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class StatusViewModel {
    var user: User?

    internal let title = localized("myaccount.settings.profile.status.title")
    internal let statusOnline = localized("status.online")
    internal let statusAway = localized("status.away")
    internal let statusBusy = localized("status.busy")
    internal let statusInvisible = localized("status.invisible")

    internal var currentStatusIndex: Int {
        guard let user = user else { return -1 }

        switch user.status {
        case .online: return 0
        case .away: return 1
        case .busy: return 2
        case .offline: return 3
        }
    }

    internal func status(for index: Int) -> UserStatus {
        switch index {
        case 0: return .online
        case 1: return .away
        case 2: return .busy
        case 3: return .offline
        default: return .online
        }
    }

    init() {
        self.user = AuthManager.currentUser()
    }
}
