//
//  NSAttributedString+Extensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SDWebImage

extension NSAttributedString {
    func applyingCustomEmojis(_ emojis: [Emoji]) -> NSAttributedString {
        let mutableSelf = NSMutableAttributedString(attributedString: self)

        return emojis.reduce(mutableSelf) { attributedString, emoji in
            guard case let .custom(imageUrl) = emoji.type else { return attributedString }

            let shortname = ":\(emoji.shortname):"

            guard let regex = try? NSRegularExpression(pattern: shortname, options: []) else { return attributedString }

            let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

            for match in matches {
                let imageAttachment = NSTextAttachment()
                imageAttachment.bounds = CGRect(x: 0, y: 0, width: 22.0, height: 22.0)
                imageAttachment.contents = imageUrl.data(using: .utf8)
                let imageString = NSAttributedString(attachment: imageAttachment)
                attributedString.replaceCharacters(in: NSRange(location: match.range.location, length: shortname.count), with: imageString)
            }

            return attributedString
        }
    }
}
