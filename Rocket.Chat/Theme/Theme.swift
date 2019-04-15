//
//  Theme.swift
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
    @objc let backgroundColor: UIColor
    @objc let focusedBackground: UIColor
    @objc let chatComponentBackground: UIColor
    @objc let auxiliaryBackground: UIColor
    @objc let bannerBackground: UIColor
    @objc let titleText: UIColor
    @objc let bodyText: UIColor
    @objc let borderColor: UIColor
    @objc let controlText: UIColor
    @objc let auxiliaryText: UIColor
    @objc let tintColor: UIColor
    @objc let auxiliaryTintColor: UIColor
    @objc let actionTintColor: UIColor
    @objc let actionBackgroundColor: UIColor
    @objc let mutedAccent: UIColor
    @objc let strongAccent: UIColor
    let appearence: Appearence

    struct Appearence: Equatable {
        let barStyle: UIBarStyle
        let keyboardAppearence: UIKeyboardAppearance
        let statusBarStyle: UIStatusBarStyle
        let scrollViewIndicatorStyle: UIScrollView.IndicatorStyle

        static let dark = Appearence(
            barStyle: .black,
            keyboardAppearence: .dark,
            statusBarStyle: .lightContent,
            scrollViewIndicatorStyle: .white
        )

        static let light = Appearence(
            barStyle: .default,
            keyboardAppearence: .default,
            statusBarStyle: .default,
            scrollViewIndicatorStyle: .black
        )
    }

    init(backgroundColor: UIColor,
         focusedBackground: UIColor,
         chatComponentBackground: UIColor,
         auxiliaryBackground: UIColor,
         bannerBackground: UIColor,
         titleText: UIColor,
         bodyText: UIColor,
         borderColor: UIColor,
         controlText: UIColor,
         auxiliaryText: UIColor,
         tintColor: UIColor,
         auxiliaryTintColor: UIColor,
         actionTintColor: UIColor,
         actionBackgroundColor: UIColor,
         mutedAccent: UIColor,
         strongAccent: UIColor?,
         appearence: Appearence) {

        self.backgroundColor = backgroundColor
        self.focusedBackground = focusedBackground
        self.chatComponentBackground = chatComponentBackground
        self.auxiliaryBackground = auxiliaryBackground
        self.bannerBackground = bannerBackground
        self.titleText = titleText
        self.bodyText = bodyText
        self.borderColor = borderColor
        self.controlText = controlText
        self.auxiliaryText = auxiliaryText
        self.tintColor = tintColor
        self.auxiliaryTintColor = auxiliaryTintColor
        self.actionTintColor = actionTintColor
        self.actionBackgroundColor = actionBackgroundColor
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
        focusedBackground: .RCNavigationBarColor(),
        chatComponentBackground: #colorLiteral(red: 0.9529411765, green: 0.9568627451, blue: 0.9607843137, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0.937, green: 0.937, blue: 0.957, alpha: 1),
        bannerBackground: #colorLiteral(red: 0.9450980392, green: 0.9490196078, blue: 0.9568627451, alpha: 1),
        titleText: #colorLiteral(red: 0.05143930763, green: 0.0585193634, blue: 0.07106169313, alpha: 1),
        bodyText: #colorLiteral(red: 0.1843137255, green: 0.2039215686, blue: 0.2392156863, alpha: 1),
        borderColor: #colorLiteral(red: 0.8823529412, green: 0.8980392157, blue: 0.9098039216, alpha: 1),
        controlText: #colorLiteral(red: 0.3294117647, green: 0.3450980392, blue: 0.368627451, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6117647059, green: 0.6352941176, blue: 0.6588235294, alpha: 1),
        tintColor: .RCBlue(),
        auxiliaryTintColor: #colorLiteral(red: 0.03921568627, green: 0.2666666667, blue: 0.4117647059, alpha: 1),
        actionTintColor: #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1),
        actionBackgroundColor: #colorLiteral(red: 0.9098039216, green: 0.9490196078, blue: 1, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.8, alpha: 1),
        strongAccent: nil,
        appearence: .light
    )

    static let dark = Theme(
        backgroundColor: #colorLiteral(red: 0.01176470588, green: 0.0431372549, blue: 0.1058823529, alpha: 1),
        focusedBackground: #colorLiteral(red: 0.0431372549, green: 0.09411764706, blue: 0.1725490196, alpha: 1),
        chatComponentBackground: #colorLiteral(red: 0.1007164493, green: 0.1329644322, blue: 0.1973000765, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0.02950551261, green: 0.06437566387, blue: 0.1180220504, alpha: 1),
        bannerBackground: #colorLiteral(red: 0.05490196078, green: 0.1215686275, blue: 0.2196078431, alpha: 1),
        titleText: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        bodyText: #colorLiteral(red: 0.9111283446, green: 0.9229556015, blue: 0.9294117647, alpha: 1),
        borderColor: #colorLiteral(red: 0.05882352941, green: 0.1294117647, blue: 0.2392156863, alpha: 1),
        controlText: #colorLiteral(red: 0.8549193462, green: 0.8697612629, blue: 0.903159703, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.5732198682, green: 0.5927470883, blue: 0.638310602, alpha: 1),
        tintColor: #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1),
        auxiliaryTintColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
        actionTintColor: #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1),
        actionBackgroundColor: #colorLiteral(red: 0.9098039216, green: 0.9490196078, blue: 1, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.1672673633, green: 0.1672673633, blue: 0.1769603646, alpha: 1),
        strongAccent: nil,
        appearence: .dark
    )

    static let black = Theme(
        backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
        focusedBackground: #colorLiteral(red: 0.05332512842, green: 0.05332512842, blue: 0.05332512842, alpha: 1),
        chatComponentBackground: #colorLiteral(red: 0.08947405964, green: 0.09412670881, blue: 0.1027644202, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0.03411494007, green: 0.03411494007, blue: 0.03411494007, alpha: 1),
        bannerBackground: #colorLiteral(red: 0.1215686275, green: 0.137254902, blue: 0.1607843137, alpha: 1),
        titleText: #colorLiteral(red: 0.9785086513, green: 0.9786720872, blue: 0.9784870744, alpha: 1),
        bodyText: #colorLiteral(red: 0.9111283446, green: 0.9229556015, blue: 0.9294117647, alpha: 1),
        borderColor: #colorLiteral(red: 0.1215686275, green: 0.137254902, blue: 0.1607843137, alpha: 1),
        controlText: #colorLiteral(red: 0.8549193462, green: 0.8697612629, blue: 0.903159703, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6980392157, green: 0.7224261515, blue: 0.7773035386, alpha: 1),
        tintColor: #colorLiteral(red: 0.1176470588, green: 0.6078431373, blue: 0.9960784314, alpha: 1),
        auxiliaryTintColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
        actionTintColor: #colorLiteral(red: 0.1176470588, green: 0.631372549, blue: 0.9960784314, alpha: 1),
        actionBackgroundColor: #colorLiteral(red: 0.9098039216, green: 0.9490196078, blue: 1, alpha: 1),
        mutedAccent: #colorLiteral(red: 0.156862745, green: 0.156862745, blue: 0.16, alpha: 1),
        strongAccent: nil,
        appearence: .dark
    )
}
