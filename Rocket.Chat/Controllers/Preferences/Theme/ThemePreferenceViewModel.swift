//
//  ThemePreferenceViewModel.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ThemePreferenceViewModel {
    let themes: [(title: String, theme: Theme)] = ThemeManager.themes.map { (localized("theme." + $0.title), $0.theme) }

    let cellIdentifier = ThemePreferenceCell.identifier
    let cellHeight = ThemePreferenceCell.cellHeight

    internal var title: String {
        return localized("theme.settings.title")
    }

    internal var header: String {
        return localized("theme.settings.header")
    }

    internal var footer: String {
        return localized("theme.settings.footer")
    }
}
