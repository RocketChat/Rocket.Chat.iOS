//
//  UINavigationItem.swift
//  Rocket.Chat
//
//  Created by Rudrank Riyam on 29/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func moreButton() {
        rightBarButtonItem?.accessibilityLabel = localized("auth.more")
    }
}
