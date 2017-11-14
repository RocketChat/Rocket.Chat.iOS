//
//  NSAttributedStringExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func heightForView(withWidth width: CGFloat) -> CGFloat? {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size,
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)

        return rect.height
    }
}

extension NSAttributedStringKey {
    public static let highlightBackgroundColor = NSAttributedStringKey(rawValue: "highlightBackgroundColor")
}

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
                NSAttributedStringKey.highlightBackgroundColor: color
            ], range: attributeRange)
        }
    }

    func setLineSpacing(_ font: UIFont) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.lineHeight * 0.1

        self.addAttributes([
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: self.length))
    }

    func transformMarkdown() -> NSAttributedString {
        return MarkdownManager.parser.attributedStringFromAttributedMarkdownString(self)
    }

    func highlightMentions(_ mentions: [String], username: String?) {
        var handledHighlights: [String] = []

        mentions.forEach { mention in
            if !handledHighlights.contains(mention) {
                handledHighlights.append(mention)

                let background: UIColor
                let font: UIColor
                if mention == username {
                    background = .primaryAction
                    font = .white
                } else if mention == "all" || mention == "here" {
                    background = .attention
                    font = .white
                } else {
                    background = .white
                    font = .link
                }

                let ranges = string.ranges(of: "@\(mention)")
                for range in ranges {
                    let range = NSRange(range, in: string)
                    setBackgroundColor(background, range: range)
                    setFontColor(font, range: range)
                }
            }
        }
    }

    func highlightChannels(_ channels: [String]) {
        var handledHighlights: [String] = []

        channels.forEach { channel in
            if !handledHighlights.contains(channel) {
                handledHighlights.append(channel)

                let ranges = string.ranges(of: "#\(channel)")
                for range in ranges {
                    let range = NSRange(range, in: string)
                    setFontColor(.link, range: range)
                }
            }
        }
    }
}
