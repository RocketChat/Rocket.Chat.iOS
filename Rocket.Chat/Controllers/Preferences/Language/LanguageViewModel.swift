//
//  LanguageViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 26.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class LanguageViewModel {
    let cellIdentifier = "changeLanguageCell"
    let resetCellIdentifier = "changeLanguageResetCell"

    internal var languages: [String] {
        return Bundle.main.localizations.filter({ code -> Bool in
            return code != "Base"
        })
    }

    internal var title: String {
        return localized("myaccount.settings.language.title")
    }

    internal var resetLabel: String {
        return localized("myaccount.settings.language.reset")
    }

    internal var message: String {
        return localized("myaccount.settings.language.message")
    }
}
