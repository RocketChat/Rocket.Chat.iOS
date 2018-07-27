//
//  SubscriptionsSortingHeaderView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/20/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsSortingHeaderView: UIView {
    override var theme: Theme? {
        guard let theme = super.theme else { return nil }
        return Theme(
            backgroundColor: theme.appearence == .light ? theme.backgroundColor : theme.focusedBackground,
            focusedBackground: theme.focusedBackground,
            auxiliaryBackground: theme.auxiliaryBackground,
            bannerBackground: theme.bannerBackground,
            titleText: theme.titleText,
            bodyText: theme.bodyText,
            controlText: theme.controlText,
            auxiliaryText: theme.auxiliaryText,
            tintColor: theme.tintColor,
            auxiliaryTintColor: theme.auxiliaryTintColor,
            hyperlink: theme.hyperlink,
            mutedAccent: theme.mutedAccent,
            strongAccent: theme.strongAccent,
            appearence: theme.appearence
        )
    }
}
