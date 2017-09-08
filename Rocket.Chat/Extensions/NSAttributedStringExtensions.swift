//
//  NSAttributedStringExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import TSMarkdownParser

extension NSMutableAttributedString {

    func trimCharacters(in set: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: set)

        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set)
        }

        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: set, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: set, options: .backwards)
        }
    }

    func setFont(_ font: UIFont, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSFontAttributeName: font
            ], range: attributeRange)
        }
    }

    func setFontColor(_ color: UIColor, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSForegroundColorAttributeName: color
            ], range: attributeRange)
        }
    }

    func setBackgroundColor(_ color: UIColor, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSBackgroundColorAttributeName: color
                ], range: attributeRange)
        }
    }

    func transformMarkdown() -> NSAttributedString {
        let defaultFontSize = MessageTextFontAttributes.defaultFontSize

        let parser = TSMarkdownParser.standard()
        parser.defaultAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: defaultFontSize)]
        parser.quoteAttributes = [[NSFontAttributeName: UIFont.italicSystemFont(ofSize: defaultFontSize)]]
        parser.strongAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: defaultFontSize)]
        parser.emphasisAttributes = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: defaultFontSize)]
        parser.linkAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]

        let font = UIFont(name: "Courier New", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
        parser.monospaceAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.red
        ]

        return parser.attributedString(fromAttributedMarkdownString: self)
    }

}
