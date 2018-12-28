//
//  JitsiViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 24/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class JitsiViewModel {

    internal var subscription: UnmanagedSubscription?

    internal var user: UnmanagedUser? {
        return AuthManager.currentUser()?.unmanaged
    }

    internal var userDisplayName: String {
        return user?.displayName ?? ""
    }

    internal var userAvatar: String {
        return user?.avatarURL?.absoluteString ?? ""
    }

    internal var analyticsSubscriptionType: String {
        return subscription?.type.rawValue ?? ""
    }

    internal var analyticsServerURL: String {
        return AuthManager.selectedServerHost()
    }

    internal var videoCallURL: String {
        guard
            let settings = AuthSettingsManager.settings,
            let domain = settings.jitsiDomain,
            let prefix = settings.jitsiPrefix,
            let rid = subscription?.rid
        else {
            return ""
        }

        let uniqueIdentifier = settings.uniqueIdentifier ?? "undefined"

        let urlProtocol = settings.isJitsiSSL ? "https://" : "http://"
        let urlDomain = "\(domain)/"

        return urlProtocol + urlDomain + prefix + uniqueIdentifier + rid
    }

}
