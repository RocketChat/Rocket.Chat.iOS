//
//  Themeable.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/25/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SlackTextViewController

class Theme: NSObject {
    let backgroundColor: UIColor
    let titleText: UIColor
    let bodyText: UIColor
    let auxiliaryText: UIColor
    let hyperlinkText: UIColor
    let tintColor: UIColor
    let focusedBackground: UIColor
    let auxiliaryBackground: UIColor
    let mutedAccent: UIColor
    let strongAccent: UIColor

    init(backgroundColor: UIColor, titleText: UIColor, bodyText: UIColor, auxiliaryText: UIColor, hyperlinkText: UIColor, tintColor: UIColor, focusedBackground: UIColor, auxiliaryBackground: UIColor, mutedAccent: UIColor?, strongAccent: UIColor?) {
        self.backgroundColor = backgroundColor
        self.titleText = titleText
        self.bodyText = bodyText
        self.auxiliaryText = auxiliaryText
        self.hyperlinkText = hyperlinkText
        self.tintColor = tintColor
        self.focusedBackground = focusedBackground
        self.auxiliaryBackground = auxiliaryBackground

        if let mutedAccent = mutedAccent {
            self.mutedAccent = mutedAccent
        } else {
            self.mutedAccent = #colorLiteral(red: 0.9953911901, green: 0.9881951213, blue: 1, alpha: 0.3031745158)
        }

        if let strongAccent = strongAccent {
            self.strongAccent = strongAccent
        } else {
            self.strongAccent = #colorLiteral(red: 0.9720572829, green: 0.3783821166, blue: 0.446572125, alpha: 1)
        }
    }

    static let dark = Theme(
        backgroundColor: #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1),
        titleText: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        bodyText: #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1),
        hyperlinkText: #colorLiteral(red: 1, green: 0.8117647059, blue: 0.231372549, alpha: 1),
        tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        focusedBackground: #colorLiteral(red: 0.1433121264, green: 0.1433121264, blue: 0.1433121264, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0, green: 0.1019607843, blue: 0.3254901961, alpha: 1),
        mutedAccent: nil,
        strongAccent: nil
    )
}

@objc protocol Themeable {
    @objc func applyTheme(_ theme: Theme)
}

extension UIView: Themeable {
    func applyTheme(_ theme: Theme) {
        backgroundColor = theme.backgroundColor.withAlphaComponent(backgroundColor?.cgColor.alpha ?? 0.0)
        subviews.forEach { $0.applyTheme(theme) }
    }
}

extension UILabel {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        textColor = theme.bodyText
    }
}

extension UICollectionView {
    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme(AppDelegate.theme)
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
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.subviews.forEach { $0.applyTheme(theme) }
        self.barTintColor = theme.backgroundColor
        self.tintColor = theme.bodyText
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme(AppDelegate.theme)
    }
}

extension UIToolbar {
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        self.isTranslucent = false
        self.barTintColor = theme.focusedBackground
        self.tintColor = theme.tintColor
    }
}
