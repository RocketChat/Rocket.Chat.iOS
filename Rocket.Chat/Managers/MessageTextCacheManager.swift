//
//  MessageTextCacheManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 02/05/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class MessageTextCacheManager {

    static let shared = MessageTextCacheManager()
    let cache = NSCache<NSString, NSAttributedString>()

    internal func cachedKey(for identifier: String) -> NSString {
        return NSString(string: "\(identifier)-cachedattrstring")
    }

    func clear() {
        cache.removeAllObjects()
    }

    func remove(for message: Message) {
        guard let identifier = message.identifier else { return }
        cache.removeObject(forKey: cachedKey(for: identifier))
    }

    @discardableResult func update(for message: Message) -> NSMutableAttributedString? {
        guard let identifier = message.identifier else { return nil }
        let key = cachedKey(for: identifier)

        let text = NSMutableAttributedString(attributedString:
            NSAttributedString(string: message.textNormalized()).applyingCustomEmojis(CustomEmoji.emojiStrings)
        )

        if message.isSystemMessage() {
            text.setFont(MessageTextFontAttributes.italicFont)
            text.setFontColor(MessageTextFontAttributes.systemFontColor)
        } else {
            text.setFont(MessageTextFontAttributes.defaultFont)
            text.setFontColor(MessageTextFontAttributes.defaultFontColor)
            text.setLineSpacing(MessageTextFontAttributes.defaultFont)
        }

        let mentions = Array(message.mentions.flatMap { $0.username })
        let channels = Array(message.channels.flatMap { $0.name })
        let username = AuthManager.currentUser()?.username

        let attributedString = text.transformMarkdown()
        let finalText = NSMutableAttributedString(attributedString: attributedString)
        finalText.trimCharacters(in: .whitespaces)
        finalText.highlightMentions(mentions, username: username)
        finalText.highlightChannels(channels)

        self.cache.setObject(finalText, forKey: key)

        return finalText
    }

    func message(for message: Message) -> NSMutableAttributedString? {
        guard let identifier = message.identifier else { return nil }
        let resultText: NSAttributedString
        let key = cachedKey(for: identifier)

        if let cachedVersion = cache.object(forKey: key) {
            resultText = cachedVersion
        } else {
            if let result = update(for: message) {
                resultText = result
            } else {
                resultText = NSAttributedString(string: message.text)
            }
        }

        return NSMutableAttributedString(attributedString: resultText)
    }

}
