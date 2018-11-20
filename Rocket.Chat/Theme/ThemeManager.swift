//
//  ThemeManager.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ThemeManager {

    /**
     Stores a default `Theme` for the app.

     Setting a new value will cause the `applyTheme` method to be called on all the `ThemeManager.observers`. The transition is animated by default.
     */

    static var theme = themes.first(where: { $0.title == themeTitle })?.theme ?? Theme.light {
        didSet {
            UIView.animate(withDuration: 0.3) {
                observers.forEach { $0.value?.applyTheme() }
            }
            let themeName = themes.first(where: { $0.theme == theme })?.title
            UserDefaults.standard.set(themeName, forKey: userDefaultsKey)
        }
    }

    static var themeTitle: String {
        return UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
    }

    static let userDefaultsKey = "RCTheme"
    static let themes: [(title: String, theme: Theme)] = [("light", .light), ("dark", .dark), ("black", .black)]

    static var observers = [Weak<Themeable>]()

    /**
     Allows for `applyTheme` to be called automatically on the `observer` when the `ThemeManager.theme` changes.

     ThemeManager holds a weak reference to the `observer`.
     */

    static func addObserver(_ observer: Themeable?) {
        observers = observers.compactMap { $0 }
        guard let observer = observer else { return }
        observer.applyTheme()
        observers.append(Weak(observer))
    }
}

struct Weak<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}

fileprivate extension Array where Element == Weak<AnyObject> {
    mutating func filterReleasedReferences() {
        self = self.compactMap { $0 }
    }
}
