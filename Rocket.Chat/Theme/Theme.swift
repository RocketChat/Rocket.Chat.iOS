//
//  Themeable.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/25/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

@objc protocol Themeable {
    func applyTheme()
}

@objc protocol ThemeProvider {
    var theme: Theme? { get }
}

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
    let appearence: Appearence

    struct Appearence: Equatable {
        let barStyle: UIBarStyle
        let keyboardAppearence: UIKeyboardAppearance
        let statusBarStyle: UIStatusBarStyle

        static let dark = Appearence(barStyle: .black, keyboardAppearence: .dark, statusBarStyle: .lightContent)
        static let light = Appearence(barStyle: .default, keyboardAppearence: .default, statusBarStyle: .default)
    }

    init(backgroundColor: UIColor,
         titleText: UIColor,
         bodyText: UIColor,
         auxiliaryText: UIColor,
         hyperlinkText: UIColor,
         tintColor: UIColor,
         focusedBackground: UIColor,
         auxiliaryBackground: UIColor,
         mutedAccent: UIColor,
         strongAccent: UIColor?,
         appearence: Appearence) {

        self.backgroundColor = backgroundColor
        self.titleText = titleText
        self.bodyText = bodyText
        self.auxiliaryText = auxiliaryText
        self.hyperlinkText = hyperlinkText
        self.tintColor = tintColor
        self.focusedBackground = focusedBackground
        self.auxiliaryBackground = auxiliaryBackground
        self.mutedAccent = mutedAccent

        if let strongAccent = strongAccent {
            self.strongAccent = strongAccent
        } else {
            self.strongAccent = #colorLiteral(red: 0.9720572829, green: 0.3783821166, blue: 0.446572125, alpha: 1)
        }

        self.appearence = appearence
    }

    static let light = Theme(
        backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        titleText: #colorLiteral(red: 0.05143930763, green: 0.0585193634, blue: 0.07106169313, alpha: 1),
        bodyText: #colorLiteral(red: 0.1843137255, green: 0.2039215686, blue: 0.2392156863, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6117647059, green: 0.6352941176, blue: 0.6588235294, alpha: 1),
        hyperlinkText: .RCBlue(),
        tintColor: .black,
        focusedBackground: .RCNavigationBarColor(),
        auxiliaryBackground: #colorLiteral(red: 0.03921568627, green: 0.2666666667, blue: 0.4117647059, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.8, alpha: 1),
        strongAccent: nil,
        appearence: .light
    )

    static let dark = Theme(
        backgroundColor: #colorLiteral(red: 0.08, green: 0.08, blue: 0.08, alpha: 1),
        titleText: #colorLiteral(red: 0.9785086513, green: 0.9786720872, blue: 0.9784870744, alpha: 1),
        bodyText: #colorLiteral(red: 0.9111283446, green: 0.9229556015, blue: 0.9294117647, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6980392157, green: 0.7224261515, blue: 0.7773035386, alpha: 1),
        hyperlinkText: #colorLiteral(red: 1, green: 0.8117647059, blue: 0.231372549, alpha: 1),
        tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        focusedBackground: #colorLiteral(red: 0.1036974415, green: 0.1036974415, blue: 0.1036974415, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2470588235, alpha: 1),
        strongAccent: nil,
        appearence: .dark
    )

    static let black = Theme(
        backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
        titleText: #colorLiteral(red: 0.9785086513, green: 0.9786720872, blue: 0.9784870744, alpha: 1),
        bodyText: #colorLiteral(red: 0.9111283446, green: 0.9229556015, blue: 0.9294117647, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6980392157, green: 0.7224261515, blue: 0.7773035386, alpha: 1),
        hyperlinkText: #colorLiteral(red: 1, green: 0.8117647059, blue: 0.231372549, alpha: 1),
        tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        focusedBackground: #colorLiteral(red: 0.04620946944, green: 0.04620946944, blue: 0.04620946944, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2, alpha: 1),
        strongAccent: nil,
        appearence: .dark
    )
}
