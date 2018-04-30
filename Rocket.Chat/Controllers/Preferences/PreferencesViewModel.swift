//
//  PreferencesViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Ramos on 31/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

internal enum BundleInfoKey: String {
    case version = "CFBundleShortVersionString"
    case build = "CFBundleVersion"
}

final class PreferencesViewModel {

    internal let title = localized("myaccount.settings.title")
    internal let profile = localized("myaccount.settings.profile")
    internal let contactus = localized("myaccount.settings.contactus")
    internal let license = localized("myaccount.settings.license")
    internal let language = localized("myaccount.settings.language")
    internal let appicon = localized("myaccount.settings.appicon")
    internal let webBrowser = localized("myaccount.settings.web_browser")
    internal let theme = localized("theme.settings.title")

    internal let licenseURL = URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")

    internal let trackingTitle = localized("myaccount.settings.tracking.title")
    internal var trackingFooterText = localized("myaccount.settings.tracking.footer")

    internal var trackingValue: Bool {
        return !BugTrackingCoordinator.isCrashReportingDisabled
    }

    internal var formattedVersion: String {
        return String(format: localized("myaccount.settings.version"), version, build)
    }

    internal var formattedServerVersion: String {
        let serverVersion = AuthManager.isAuthenticated()?.serverVersion ?? "?"
        return String(format: localized("myaccount.settings.server_version"), serverVersion)
    }

    internal var serverAddress: String {
        return AuthManager.isAuthenticated()?.apiHost?.host ?? ""
    }

    internal var version: String {
        return appInfo(.version)
    }

    internal var build: String {
        return appInfo(.build)
    }

    internal let supportEmail = "Rocket.Chat Support <support@rocket.chat>"

    internal let supportEmailSubject = "Support on iOS native application"

    internal var supportEmailBody: String {
        return """
        <br /><br />
        <b>Device information</b><br />
        <b>System name</b>: \(UIDevice.current.systemName)<br />
        <b>System version</b>: \(UIDevice.current.systemVersion)<br />
        <b>System model</b>: \(UIDevice.current.model)<br />
        <b>Application version</b>: \(version) (\(build))
        """
    }

    internal var canChangeAppIcon: Bool {
        if #available(iOS 10.3, *) {
            return UIApplication.shared.supportsAlternateIcons
        } else {
            return false
        }
    }

    #if DEBUG || BETA
    internal let canOpenFLEX = true
    #else
    internal let canOpenFLEX = false
    #endif

    internal let numberOfSections = 5

    internal func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return (canChangeAppIcon ? 5 : 4)
        case 2: return 3
        case 3: return 1
        case 4: return (canOpenFLEX ? 1 : 0)
        default: return 0
        }
    }

    // MARK: Helpers

    internal func appInfo(_ info: BundleInfoKey) -> String {
        return Bundle.main.infoDictionary?[info.rawValue] as? String ?? ""
    }
}
