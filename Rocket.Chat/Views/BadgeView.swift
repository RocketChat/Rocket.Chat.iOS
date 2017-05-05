//
//  BadgeView.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class BadgeLabel: UILabel {

    init(withTarget target: UIView?) {
        self.target = target
        super.init(frame: CGRect.zero)

        textAlignment = .center
        textColor = UIColor.white
        backgroundColor = UIColor.red
        clipsToBounds = true

        layoutBadge()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var text: String? {
        didSet {
            self.isHidden = text == nil
            if text != nil {
                layoutBadge()
            }
        }
    }

    var target: UIView? = nil {
        didSet {
            layoutBadge()
        }
    }

    var edgeInsets = UIEdgeInsets.zero {
        didSet {
            layoutBadge()
        }
    }

    var padding = CGSize(width: 6, height: 0) {
        didSet {
            layoutBadge()
        }
    }

    var minSize = CGSize(width: 20, height: 20) {
        didSet {
            layoutBadge()
        }
    }

    private var badgeExpectedOrigin: CGPoint {
        guard let superView = target else { return CGPoint.zero }
        var x = superView.frame.width - minSize.width - padding.width - edgeInsets.right
        if x < edgeInsets.left {
            x = edgeInsets.left
        }
        let y = edgeInsets.top
        return CGPoint(x: x, y: y)
    }

    private var badgeExpectedSize: CGSize {
        var size = self.frame.size
        size.height = minSize.height < size.height ? size.height : minSize.height
        size.width = minSize.width < size.width ? size.width : minSize.width
        size.height += padding.height
        size.width += padding.width
        return size
    }

    private func layoutBadge() {
        self.sizeToFit()
        self.frame = CGRect(origin: badgeExpectedOrigin, size: badgeExpectedSize)
        self.layer.cornerRadius = frame.height / 2
    }

}
