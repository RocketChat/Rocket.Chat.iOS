//
//  MessageTextCacheManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 02/05/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessageAttributedString {
    let string: NSAttributedString
    let theme: Theme?

    init(string: NSAttributedString, theme: Theme?) {
        self.string = string
        self.theme = theme
    }
}

final class MessageTextCacheManager {

    static let shared = MessageTextCacheManager()
    let cache = NSCache<NSString, MessageAttributedString>()

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

    @discardableResult func update(for message: UnmanagedMessage, with theme: Theme? = nil) -> NSMutableAttributedString? {
        let key = cachedKey(for: message.identifier)

        let text = NSMutableAttributedString(attributedString:
            NSAttributedString(string: message.textNormalized()).applyingCustomEmojis(CustomEmoji.emojiStrings)
        )

        if message.isSystemMessage() {
            text.setFont(MessageTextFontAttributes.italicFont)
            text.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
        } else {
            text.setFont(MessageTextFontAttributes.defaultFont)
            text.setFontColor(MessageTextFontAttributes.defaultFontColor(for: theme))
            text.setLineSpacing(MessageTextFontAttributes.defaultFont)
        }

        let mentions = message.mentions
        let channels = message.channels.compactMap { $0.name }
        let username = AuthManager.currentUser()?.username

        let attributedString = text.transformMarkdown(with: theme)
        let finalText = NSMutableAttributedString(attributedString: attributedString)

        finalText.trimCharacters(in: .whitespaces)
        finalText.highlightMentions(mentions, currentUsername: username)
        finalText.highlightChannels(channels)

        let cachedObject = MessageAttributedString(string: finalText, theme: theme)
        cache.setObject(cachedObject, forKey: key)
        return finalText
    }

    @discardableResult
    func message(for message: UnmanagedMessage, with theme: Theme? = nil) -> NSMutableAttributedString? {
        var resultText: NSAttributedString?
        let key = cachedKey(for: message.identifier)

        if let cachedVersion = cache.object(forKey: key), theme == nil || cachedVersion.theme == theme {
            resultText = cachedVersion.string
        } else if let result = update(for: message, with: theme) {
            resultText = result
        }

        if let resultText = resultText {
            return NSMutableAttributedString(attributedString: resultText)
        }

        return nil
    }

}
