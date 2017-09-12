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
                NSAttributedStringKey.font: font
            ], range: attributeRange)
        }
    }

    func setFontColor(_ color: UIColor, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedStringKey.foregroundColor: color
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
        parser.defaultAttributes = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: defaultFontSize)]
        parser.quoteAttributes = [[NSAttributedStringKey.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize)]]
        parser.strongAttributes = [NSAttributedStringKey.font.rawValue: UIFont.boldSystemFont(ofSize: defaultFontSize)]
        parser.emphasisAttributes = [NSAttributedStringKey.font.rawValue: UIFont.italicSystemFont(ofSize: defaultFontSize)]
        parser.linkAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray]

        let font = UIFont(name: "Courier New", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
        parser.monospaceAttributes = [
            NSAttributedStringKey.font.rawValue: font,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.red
        ]

        return parser.attributedString(fromAttributedMarkdownString: self)
    }

    func highlightMentions(for message: Message) {
        message.mentions.forEach {
            if let username = $0.username {
                let ranges = string.ranges(of: "@\(username)")
                for range in ranges {
                    let range = NSRange(range, in: string)
                    setBackgroundColor(UIColor.background(for: $0), range: range)
                    setFontColor(UIColor.font(for: $0), range: range)
                }
            }
        }
    }

    func highlightChannels(for message: Message) {
        message.channels.forEach {
            if let name = $0.name {
                let ranges = string.ranges(of: "#\(name)")
                for range in ranges {
                    let range = NSRange(range, in: string)
                    setFontColor(.link, range: range)
                }
            }
        }
    }
}
