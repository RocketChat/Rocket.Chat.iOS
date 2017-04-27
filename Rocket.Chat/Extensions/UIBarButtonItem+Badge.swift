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
        static var badge = "badge"
        static var badgeEdgeInsets = "badgeEdgeInsets"
        static var badgePadding = "badgePadding"
        static var badgeMinSize = "badgeMinSize"
        static var badgeLabel = "badgeLabel"
    }

    var badge: String? {
        get {
            return objc_getAssociatedObject(self, &BadgeExtension.badge) as? String
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badge, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            badgeLabel.text = newValue
            resizeBadge()
            if newValue == nil {
                badgeLabel.isHidden = true
            } else {
                badgeLabel.isHidden = false
            }
        }
    }

    var badgeEdgeInsets: UIEdgeInsets {
        get {
            guard let insets = objc_getAssociatedObject(self, &BadgeExtension.badgeEdgeInsets) as? UIEdgeInsets else {
                return UIEdgeInsets.zero
            }
            return insets
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badgeEdgeInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            layoutBadge()
        }
    }

    var badgePadding: CGSize {
        get {
            guard let padding = objc_getAssociatedObject(self, &BadgeExtension.badgePadding) as? CGSize else {
                return CGSize(width: 6, height: 0)
            }
            return padding
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badgePadding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            layoutBadge()
        }
    }

    var badgeMinSize: CGSize {
        get {
            guard let size = objc_getAssociatedObject(self, &BadgeExtension.badgeMinSize) as? CGSize else {
                return CGSize(width: 20, height: 20)
            }
            return size
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badgeMinSize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            layoutBadge()
        }
    }

    var badgeLabel: UILabel {
        get {
            guard let label = objc_getAssociatedObject(self, &BadgeExtension.badgeLabel) as? UILabel else {
                var size = badgeMinSize
                size.height += badgePadding.height
                size.width += badgePadding.width
                let defaultLabel = UILabel(frame: CGRect(origin: badgeExpectedOrigin, size: size))
                defaultLabel.textAlignment = .center
                defaultLabel.textColor = UIColor.white
                defaultLabel.backgroundColor = UIColor.red
                defaultLabel.layer.cornerRadius = size.height / 2
                defaultLabel.clipsToBounds = true
                defaultLabel.isHidden = badge == nil
                defaultLabel.text = badge
                self.badgeLabel = defaultLabel
                badgeSuperView?.addSubview(defaultLabel)
                return defaultLabel
            }
            return label
        }
        set {
            objc_setAssociatedObject(self, &BadgeExtension.badgeLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            layoutBadge()
        }
    }

    private var badgeExpectedOrigin: CGPoint {
        guard let superView = badgeSuperView else { return CGPoint.zero }
        var x = superView.frame.width - badgeMinSize.width - badgePadding.width - badgeEdgeInsets.right
        if x < badgeEdgeInsets.left {
            x = badgeEdgeInsets.left
        }
        let y = badgeEdgeInsets.top
        return CGPoint(x: x, y: y)
    }

    private var badgeExpectedSize: CGSize {
        var size = badgeLabel.frame.size
        size.height = badgeMinSize.height < size.height ? size.height : badgeMinSize.height
        size.width = badgeMinSize.width < size.width ? size.width : badgeMinSize.width
        size.height += badgePadding.height
        size.width += badgePadding.width
        return size
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

    private func resizeBadge() {
        badgeLabel.sizeToFit()
        badgeLabel.frame.size = badgeExpectedSize
        badgeLabel.layer.cornerRadius = badgeExpectedSize.height / 2
    }

    private func layoutBadge() {
        badgeLabel.frame = CGRect(origin: badgeExpectedOrigin, size: badgeExpectedSize)
    }

}
