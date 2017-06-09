//
//  UIBarButtonItem+Badge.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 4/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension UIBarButtonItem {

    func addBadge(_ badge: BadgeView) {
        badgeSuperView?.addSubview(badge)
        badge.target = badgeSuperView
    }

    private var badgeSuperView: UIView? {
        if self.customView != nil {
            return self.customView
        } else if self.responds(to: #selector(getter: UITouch.view)) {
            return self.perform(#selector(getter: UITouch.view))?.takeRetainedValue() as? UIView
        } else {
            return nil
        }
    }

}
