//
//  ChangeAppIconViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 08.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class ChangeAppIconViewModel {
    let cellIdentifier = "changeAppIconCell"

    internal var title: String {
        return localized("myaccount.settings.changeicon.title")
    }

    internal var header: String {
        return localized("myaccount.settings.changeicon.header")
    }

    internal var errorTitle: String {
        return localized("myaccount.settings.changeicon.errortitle")
    }

    internal var iosVersionMessage: String {
        return localized("myaccount.settings.changeicon.iosversion")
    }

    // Adding more available icons require proper entries in Info.plist file
    let availableIcons: [(iconName: String, iconAccessibilityName: String)] = [
        ("Default", "preferences.icon.default"),
        ("Black", "preferences.icon.black"),
        ("Red", "preferences.icon.red"),
        ("BnW", "preferences.icon.bnw"),
        ("Grey", "preferences.icon.grey"),
        ("White", "preferences.icon.white"),
        ("Blue", "preferences.icon.blue")
    ]
}
