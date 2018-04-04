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

    internal var title: String {
        return localized("myaccount.settings.title")
    }

    internal var profile: String {
        return localized("myaccount.settings.profile")
    }

    internal var contactus: String {
        return localized("myaccount.settings.contactus")
    }

    internal var license: String {
        return localized("myaccount.settings.license")
    }

    internal var language: String {
        return localized("myaccount.settings.language")
    }

    internal var appicon: String {
        return localized("myaccount.settings.appicon")
    }

    internal var webBrowser: String {
        return localized("myaccount.settings.web_browser")
    }

    internal var formattedVersion: String {
        return String(format: localized("myaccount.settings.version"), version, build)
    }

    internal var version: String {
        return appInfo(.version)
    }

    internal var build: String {
        return appInfo(.build)
    }

    internal var supportEmail: String {
        return "Rocket.Chat Support <support@rocket.chat>"
    }

    internal var supportEmailSubject: String {
        return "Support on iOS native application"
    }

    internal var supportEmailBody: String {
        var text = "<br /><br />"
        text += "<b>Device information</b><br />"
        text += "<b>System name</b>: \(UIDevice.current.systemName)<br />"
        text += "<b>System version</b>: \(UIDevice.current.systemVersion)<br />"
        text += "<b>System model</b>: \(UIDevice.current.model)<br />"
        text += "<b>Application version</b>: \(version) (\(build))"
        return text
    }

    internal var licenseURL: URL? {
        return URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
    }

    internal var canChangeAppIcon: Bool {
        if #available(iOS 10.3, *) {
            return UIApplication.shared.supportsAlternateIcons
        } else {
            return false
        }
    }

    #if DEBUG || BETA
    internal var canOpenFLEX = true
    #else
    internal var canOpenFLEX = false
    #endif

    internal var numberOfSections: Int {
        return 4
    }

    internal func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return (canChangeAppIcon ? 4 : 3)
        case 2: return 2
        case 3: return (canOpenFLEX ? 1 : 0)
        default: return 0
        }
    }

    // MARK: Helpers

    internal func appInfo(_ info: BundleInfoKey) -> String {
        return Bundle.main.infoDictionary?[info.rawValue] as? String ?? ""
    }
}
