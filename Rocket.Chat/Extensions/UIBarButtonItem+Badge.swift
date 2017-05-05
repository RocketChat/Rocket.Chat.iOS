//
//  UIBarButtonItem+Badge.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 4/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import ObjectiveC

extension UIBarButtonItem {

    struct BadgeExtension {
        static var badgeLabel = "badgeLabel"
    }

    var badgeLabel: BadgeLabel {
        get {
            guard let label = objc_getAssociatedObject(self, &BadgeExtension.badgeLabel) as? BadgeLabel else {
                let defaultLabel = BadgeLabel(withTarget: badgeSuperView)
                self.badgeLabel = defaultLabel
                badgeSuperView?.addSubview(defaultLabel)
                return defaultLabel
            }
            return label
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badgeLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
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
