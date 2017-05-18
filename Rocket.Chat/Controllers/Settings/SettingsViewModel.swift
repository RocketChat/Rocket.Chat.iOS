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

private enum Settings: Int {
    case website, contact, license

    func url() -> URL? {
        switch self {
        case .website:
            return URL(string: "https://rocket.chat")
        case .contact:
            return URL(string: "https://rocket.chat/contact")
        case .license:
            return URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
        }
    }
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

    func settingsURL(atIndex index: Int) -> URL? {
        return Settings(rawValue: index)?.url()
    }

    // MARK: Helpers

    private func appInfo(_ info: BundleInfoKey) -> String {
        return Bundle.main.infoDictionary?[info.rawValue] as? String ?? ""
    }
}
