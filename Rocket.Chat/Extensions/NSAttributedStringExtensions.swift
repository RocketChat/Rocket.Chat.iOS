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

        let rect = self.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return rect.height
    }
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
                NSAttributedString.Key.font: font
            ], range: attributeRange)
        }
    }

    func setFontColor(_ color: UIColor, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedString.Key.foregroundColor: color
            ], range: attributeRange)
        }
    }

    func setBackgroundColor(_ color: UIColor, range: NSRange? = nil) {
        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedString.Key.backgroundColor: color
            ], range: attributeRange)
        }
    }

    func setMention(_ mention: String, range: NSRange? = nil) {
        let link = "rocketchat://mention?name=\(mention)"

        let attributeRange = range ?? NSRange(location: 0, length: self.length)

        self.addAttributes([
            NSAttributedString.Key.link: link
        ], range: attributeRange)
    }

    func padLeftAndRight(range: NSRange) -> NSRange {
        // "\u{00a0}" = non-line-breaking space character
        self.insert(NSAttributedString(string: "\u{00a0}"), at: range.location)
        self.insert(NSAttributedString(string: "\u{00a0}"), at: range.location + range.length + 1)
        return NSRange(location: range.location, length: range.length + 2)
    }

    func removeAtSymbol(range: NSRange) -> NSRange {
        self.replaceCharacters(
            in: NSRange(location: range.location + 1, length: 1),
            with: ""
        )

        return NSRange(location: range.location, length: range.length - 1)
    }

    func setChannel(_ channel: String, range: NSRange? = nil) {
        let link = "rocketchat://channel?name=\(channel)"

        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedString.Key.link: link
            ], range: attributeRange)
        }
    }

    func setLineSpacing(_ font: UIFont) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.lineHeight * 0.1

        self.addAttributes([
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: self.length))
    }

    func transformMarkdown() -> NSAttributedString {
        return MarkdownManager.shared.transformAttributedString(self)
    }

    func transformMarkdown(with theme: Theme?) -> NSAttributedString {
        return MarkdownManager.shared.transformAttributedString(self, with: theme)
    }

    func highlightMentions(_ mentions: [UnmanagedMention], currentUsername: String?) {
        var handledHighlights: [String] = []
        let shouldUseRealName = AuthSettingsManager.shared.settings?.useUserRealName ?? false

        if shouldUseRealName {
            mentions.forEach { mention in
                let realName = mention.realName ?? ""
                let username = mention.username ?? ""

                if shouldUseRealName {
                    mutableString.setString(string.replacingOccurrences(of: username, with: realName))
                }
            }
        }

        let theme = ThemeManager.theme

        mentions.forEach { mention in
            let realName = mention.realName ?? ""
            let username = mention.username ?? ""

            if !handledHighlights.contains(username) {
                handledHighlights.append(username)

                let background: UIColor
                let font: UIColor
                if username == currentUsername {
                    background = theme.actionTintColor
                    font = .white
                } else if username == "all" || username == "here" {
                    background = .attention
                    font = .white
                } else {
                    background = theme.actionBackgroundColor
                    font = theme.actionTintColor
                }

                let ranges = string.ranges(of: "@\(shouldUseRealName ? realName : username)")

                var offset = 0

                for range in ranges {
                    let range = NSRange(range, in: string)
                    var transformedRange = NSRange(location: range.location + offset, length: range.length)

                    transformedRange = padLeftAndRight(range: transformedRange)
                    transformedRange = removeAtSymbol(range: transformedRange)

                    if username != "all" && username != "here" && username != currentUsername {
                        setMention(username, range: transformedRange)
                    }

                    offset = transformedRange.length - range.length

                    setBackgroundColor(background, range: transformedRange)
                    setFontColor(font, range: transformedRange)
                    setFont(MessageTextFontAttributes.boldFont, range: transformedRange)
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
                    setChannel(channel, range: range)
                    setFontColor(.primaryAction, range: range)
                }
            }
        }
    }
}
