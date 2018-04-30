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
    static var theme = Theme.dark {
        didSet {
            UIView.animate(withDuration: 0.3) {
                observers.forEach { $0?.applyTheme() }
            }
        }
    }

    static var observers = [Themeable?]()
    static func addObserver(_ observer: Themeable?) {
        observers = observers.compactMap { $0 }
        guard let observer = observer else { return }
        observer.applyTheme()
        weak var weakObserver = observer
        observers.append(weakObserver)
    }
}

@objc protocol Themeable {
    func applyTheme()
//    var theme: Theme? { get }
}

extension UIView: Themeable {
    func applyTheme() {
        guard let theme = theme else { return }
        backgroundColor = theme.backgroundColor.withAlphaComponent(backgroundColor?.cgColor.alpha ?? 0.0)
        self.subviews.forEach { $0.applyTheme() }
    }

    @objc var theme: Theme? {
        guard let superview = superview else { return ThemeManager.theme }
        return superview.theme
    }
}

extension UILabel {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        textColor = theme.titleText
    }
}

extension UITextField {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        textColor = theme.titleText
    }
}

extension UISearchBar {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        barStyle = theme.appearence.barStyle
        tintColor = theme.hyperlinkText
        keyboardAppearance = .light
    }
}

// TODO: Set the correct color
extension UIActivityIndicatorView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        activityIndicatorViewStyle = .gray
        color = .white
    }
}

extension UICollectionView {
    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.applyTheme()
    }
}

extension UITableView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        if theme == .dark || theme == .black {
            backgroundColor = style == .grouped ? theme.focusedBackground : theme.backgroundColor
        } else {
            backgroundColor = style == .grouped ? #colorLiteral(red: 0.937, green: 0.937, blue: 0.957, alpha: 1) : theme.backgroundColor
        }
        separatorColor = theme.mutedAccent
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.applyTheme()
    }
}

extension SLKTextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        self.textColor = theme.bodyText
        self.layer.borderColor = #colorLiteral(red: 0.497693181, green: 0.494099319, blue: 0.5004472733, alpha: 0.1518210827)
        self.backgroundColor = #colorLiteral(red: 0.497693181, green: 0.494099319, blue: 0.5004472733, alpha: 0.04910321301)
    }
}

extension UITextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        self.tintColor = theme.hyperlinkText
    }
}

extension UINavigationBar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        self.subviews.forEach { $0.applyTheme() }
        self.tintColor = theme.bodyText
        self.barStyle = theme.appearence.barStyle
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UIToolbar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        self.isTranslucent = false
        self.barTintColor = theme.focusedBackground
        self.tintColor = theme.tintColor
        self.barStyle = theme.appearence.barStyle
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UITabBar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        self.barTintColor = theme.focusedBackground
        self.tintColor = theme.tintColor
        self.barStyle = theme.appearence.barStyle
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension SLKTextInputbar {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        textView.keyboardAppearance = theme.appearence.keyboardAppearence
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UIViewController: Themeable {
    func applyTheme() {
        view.applyTheme()
        navigationController?.navigationBar.applyTheme()
    }
}
