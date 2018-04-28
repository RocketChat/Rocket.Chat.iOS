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
            self.mutedAccent = #colorLiteral(red: 0.4910559654, green: 0.4938107133, blue: 0.500592351, alpha: 0.1020851672)
        }

        if let strongAccent = strongAccent {
            self.strongAccent = strongAccent
        } else {
            self.strongAccent = #colorLiteral(red: 0.9720572829, green: 0.3783821166, blue: 0.446572125, alpha: 1)
        }
    }

    static let light = Theme(
        backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        titleText: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
        bodyText: .darkGray,
        auxiliaryText: .lightGray,
        hyperlinkText: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1),
        tintColor: .black,
        focusedBackground: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0, green: 0.1019607843, blue: 0.3254901961, alpha: 1),
        mutedAccent: nil,
        strongAccent: nil
    )

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

    static let black = Theme(
        backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
        titleText: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        bodyText: #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1),
        auxiliaryText: #colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1),
        hyperlinkText: #colorLiteral(red: 1, green: 0.8117647059, blue: 0.231372549, alpha: 1),
        tintColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        focusedBackground: #colorLiteral(red: 0.04620946944, green: 0.04620946944, blue: 0.04620946944, alpha: 1),
        auxiliaryBackground: #colorLiteral(red: 0, green: 0.1019607843, blue: 0.3254901961, alpha: 1),
        mutedAccent: nil,
        strongAccent: nil
    )
}
