//
//  ThemeManager.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SlackTextViewController

struct ThemeManager {
    static var theme = themes.first(where: { $0.title == UserDefaults.standard.string(forKey: userDefaultsKey) })?.theme ?? Theme.light {

        didSet {
            UIView.animate(
                withDuration: 0.3,
                animations: ({ observers.forEach { $0?.applyTheme() } })
            ) { _ in
                let themeName = themes.first(where: { $0.theme == theme })?.title
                UserDefaults.standard.set(themeName, forKey: userDefaultsKey)
            }
        }
    }

    static let userDefaultsKey = "RCTheme"
    static let themes: [(title: String, theme: Theme)] = [("light", .light), ("dark", .dark), ("black", .black)]

    static var observers = [Themeable?]()
    static func addObserver(_ observer: Themeable?) {
        observers = observers.compactMap { $0 }
        guard let observer = observer else { return }
        observer.applyTheme()
        weak var weakObserver = observer
        observers.append(weakObserver)
    }
}
