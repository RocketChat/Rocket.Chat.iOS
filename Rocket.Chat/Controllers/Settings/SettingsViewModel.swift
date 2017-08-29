//
//  SettingsViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Ramos on 31/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

private enum BundleInfoKey: String {
    case version = "CFBundleShortVersionString"
    case build = "CFBundleVersion"
}

final class SettingsViewModel {

    internal var formattedVersion: String {
        return "Version: \(version) (\(build))"
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

    // MARK: Helpers

    private func appInfo(_ info: BundleInfoKey) -> String {
        return Bundle.main.infoDictionary?[info.rawValue] as? String ?? ""
    }
}
