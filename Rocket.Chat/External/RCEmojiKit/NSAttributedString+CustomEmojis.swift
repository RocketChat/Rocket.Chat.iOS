//
//  NSAttributedString+CustomEmojis.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SDWebImage

extension NSAttributedString {
    func applyingCustomEmojis(_ emojis: [String: Emoji]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        let regexPattern = ":(\\w+|-|\\+)*:"

        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else { return attributedString }

        let ranges = regex.matches(
            in: attributedString.string,
            options: [],
            range: NSRange(location: 0, length: attributedString.length)
            ).map {
                $0.range(at: 0)
        }

        // exclude matches inside code tags
        let filteredRanges = attributedString.string.filterOutRangesInsideCode(ranges: ranges)

        var offset = 0
        for range in filteredRanges {
            let imageAttachment = NSTextAttachment()
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: 22.0, height: 22.0)
            let transformedRange = NSRange(location: range.location - offset, length: range.length)
            let replacementString = attributedString.attributedSubstring(from: transformedRange)

            if let emoji = emojis[replacementString.string.replacingOccurrences(of: ":", with: "")], let imageUrl = emoji.imageUrl {

                imageAttachment.contents = imageUrl.data(using: .utf8)
                let imageString = NSAttributedString(attachment: imageAttachment)
                attributedString.replaceCharacters(in: transformedRange, with: imageString)

                offset += replacementString.length - 1
            }
        }

        return attributedString
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

        let filteredRanges = ranges.filter { range in
            !codeRanges.contains { codeRange in
                NSIntersectionRange(codeRange, range).length == range.length
            }
        }

        return filteredRanges
    }

    func escapingRegex() -> String? {
        var escaped = self
        ["[", "]", "(", ")", "*", "+", "?", ".", "^", "$", "|"].forEach {
            escaped = escaped.replacingOccurrences(of: $0, with: "\\\($0)")
        }
        return escaped
    }
}
