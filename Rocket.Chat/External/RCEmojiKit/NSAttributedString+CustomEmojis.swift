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

            let alternates = emoji.alternates.filter { !$0.isEmpty }

            let regexPattern = ":\(emoji.shortname):" + (alternates.isEmpty ? "" : "|:\(alternates.joined(separator: ":|:")):")

            guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else { return attributedString }

            let ranges = regex.matches(
                in: attributedString.string,
                options: [],
                range: NSRange(location: 0, length: attributedString.length)
            ).map {
                $0.range(at: 0)
            }.reduce([NSRange](), { total, current in // subtract previous ranges lengths from each range location
                let offset = total.reduce(0, { $0 + $1.length - 1 })
                let range = NSRange(location: current.location - offset, length: current.length)
                return total + [range]
            })

            // exclude matches inside code tags
            let filteredRanges = attributedString.string.filterOutRangesInsideCode(ranges: ranges)

            for range in filteredRanges {
                let imageAttachment = NSTextAttachment()
                imageAttachment.bounds = CGRect(x: 0, y: 0, width: 22.0, height: 22.0)
                imageAttachment.contents = imageUrl.data(using: .utf8)
                let imageString = NSAttributedString(attachment: imageAttachment)
                attributedString.replaceCharacters(in: range, with: imageString)
            }

            return attributedString
        }
    }
}

extension String {
    func codeRanges() -> [NSRange] {
        let codeRegex = try? NSRegularExpression(pattern: "(```)(?:[a-zA-Z]+)?((?:.|\r|\n)*?)(```)", options: [.anchorsMatchLines])
        let codeMatches = codeRegex?.matches(in: self, options: [], range: NSRange(location: 0, length: count)) ?? []
        return codeMatches.map { $0.range(at: 0) }
    }

    func filterOutRangesInsideCode(ranges: [NSRange]) -> [NSRange] {
        let codeRanges = self.codeRanges()

        let filteredMatches = ranges.filter { range in
            !codeRanges.contains {
                range.location >= $0.location && range.length <= $0.length
            }
        }

        return filteredMatches
    }
}
