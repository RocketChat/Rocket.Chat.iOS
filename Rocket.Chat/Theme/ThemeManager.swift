//
//  ThemeManager.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ThemeManager {
    static var theme = themes.first(where: { $0.title == UserDefaults.standard.string(forKey: userDefaultsKey) })?.theme ?? Theme.light {

        didSet {
            UIView.animate(withDuration: 0.3) {
                observers.forEach { $0.value?.applyTheme() }
            }
            let themeName = themes.first(where: { $0.theme == theme })?.title
            UserDefaults.standard.set(themeName, forKey: userDefaultsKey)
        }
    }

    static let userDefaultsKey = "RCTheme"
    static let themes: [(title: String, theme: Theme)] = [("light", .light), ("dark", .dark), ("black", .black)]

    static var observers = [Weak<Themeable>]()
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

extension Array where Element == Weak<AnyObject> {
    mutating func filterReleasedReferences() {
        self = self.compactMap { $0 }
    }
}
