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

    func message(for message: Message) -> NSMutableAttributedString {
        let resultText: NSAttributedString
        let key = NSString(string: "\(message.identifier ?? "")-cachedstring")

        if let cachedVersion = cache.object(forKey: key) {
            resultText = cachedVersion
        } else {
            let text = NSMutableAttributedString(string: message.textNormalized())

            if message.isSystemMessage() {
                text.setFont(MessageTextFontAttributes.italicFont)
                text.setFontColor(MessageTextFontAttributes.systemFontColor)
            } else {
                text.setFont(MessageTextFontAttributes.defaultFont)
                text.setFontColor(MessageTextFontAttributes.defaultFontColor)
            }

            resultText = text.transformMarkdown()
            cache.setObject(resultText, forKey: key)
        }

        return NSMutableAttributedString(attributedString: resultText)
    }

}
