//
//  UILabelExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension UILabel {

    static func sizeForView(_ text: String, font: UIFont, width: CGFloat, lineBreakMode: NSLineBreakMode = .byClipping) -> CGSize {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

}
