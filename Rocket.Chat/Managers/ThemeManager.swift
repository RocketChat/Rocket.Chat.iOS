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
    static let theme = Theme.dark
}

@objc protocol Themeable {
    func applyTheme(_ theme: Theme)
    var theme: Theme? { get }
}

extension UIView: Themeable {
    func applyTheme(_ theme: Theme) {
        backgroundColor = theme.backgroundColor.withAlphaComponent(backgroundColor?.cgColor.alpha ?? 0.0)
        subviews.forEach { $0.applyTheme(theme) }
    }

    var theme: Theme? { return superview?.theme }
}

extension UILabel {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        textColor = theme.bodyText
    }
}

extension UISearchBar {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        barStyle = .black
        tintColor = theme.hyperlinkText
        keyboardAppearance = .dark
    }
}

extension UICollectionView {
    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }
}

extension SLKTextView {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.textColor = theme.bodyText
        self.layer.borderColor = theme.mutedAccent.cgColor
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.04910321301)
    }
}

extension UITextView {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.tintColor = theme.hyperlinkText
    }
}

extension UINavigationBar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.subviews.forEach { $0.applyTheme(theme) }
        self.barTintColor = theme.backgroundColor
        self.tintColor = theme.bodyText
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }
}

extension UIToolbar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.isTranslucent = false
        self.barTintColor = theme.focusedBackground
        self.tintColor = theme.tintColor
        self.barStyle = .black
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }
}

extension UITabBar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.barTintColor = theme.focusedBackground
        self.tintColor = theme.tintColor
        self.barStyle = .black
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }
}

extension SLKTextInputbar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        textView.keyboardAppearance = .dark
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        if let theme = theme {
            view.applyTheme(theme)
        }
    }
}
