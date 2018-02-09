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
    let availableIcons = [
        "Default",
        "Black",
        "Red",
        "BnW",
        "Grey",
        "White",
        "Blue"
    ]
}
