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
                NSAttributedStringKey.backgroundColor: color
            ], range: attributeRange)
        }
    }

    func setMention(_ mention: String, range: NSRange? = nil) {
        let link = "rocketchat://mention?name=\(mention)"

        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedStringKey.link: link
            ], range: attributeRange)
        }
    }

    func setChannel(_ channel: String, range: NSRange? = nil) {
        let link = "rocketchat://channel?name=\(channel)"

        if let attributeRange = range != nil ? range : NSRange(location: 0, length: self.length) {
            self.addAttributes([
                NSAttributedStringKey.link: link
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
        return MarkdownManager.shared.transformAttributedString(self)
    }

    func highlightMentions(_ mentions: [Mention], currentUsername: String?) {
        var handledHighlights: [String] = []

        mentions.forEach { mention in
            let shouldUseRealName = AuthSettingsManager.shared.settings?.useUserRealName ?? false
            let realName = mention.realName ?? ""
            let username = mention.username ?? ""

            if !handledHighlights.contains(username) {
                handledHighlights.append(username)

                let background: UIColor
                let font: UIColor
                if username == currentUsername {
                    background = .primaryAction
                    font = .white

                    if shouldUseRealName {
                        mutableString.setString(string.replacingFirstOccurrence(of: username, with: realName))
                    }
                } else if username == "all" || username == "here" {
                    background = .attention
                    font = .white
                } else {
                    background = .white
                    font = .link

                    if shouldUseRealName && !realName.isEmpty {
                        mutableString.setString(string.replacingFirstOccurrence(of: username, with: realName))
                    }
                }

                let ranges = string.ranges(of: "@\(shouldUseRealName ? realName : username)")
                for range in ranges {
                    let range = NSRange(range, in: string)

                    if username != "all" && username != "here" && username != currentUsername {
                        setMention(username, range: range)
                    }

                    setBackgroundColor(background, range: range)
                    setFontColor(font, range: range)
                    setFont(MessageTextFontAttributes.boldFont, range: range)
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
                    setFontColor(.link, range: range)
                }
            }
        }
    }
}
