//
//  TagLabel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 14.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class TagLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
