//
//  NSAttributedString+CustomEmojis.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func applyingCustomEmojis(_ emojis: [String: Emoji]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)

        var ranges = NSMutableAttributedString.getMatches(from: attributedString)
        let notMatched = NSMutableAttributedString.insertEmojis(emojis, into: attributedString, in: string.filterOutRangesInsideCode(ranges: ranges))
        ranges = NSMutableAttributedString.getMatches(from: attributedString, excludingRanges: notMatched)
        NSMutableAttributedString.insertEmojis(emojis, into: attributedString, in: string.filterOutRangesInsideCode(ranges: ranges))

        return attributedString
    }
}

extension NSMutableAttributedString {

    @discardableResult
    static func insertEmojis(_ emojis: [String: Emoji], into string: NSMutableAttributedString, in ranges: [NSRange]) -> [NSRange] {
        var offset = 0
        var notMatched = [NSRange]()

        for range in ranges {
            let imageAttachment = NSTextAttachment()
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: 22.0, height: 22.0)
            let transformedRange = NSRange(location: range.location - offset, length: range.length)
            let replacementString = string.attributedSubstring(from: transformedRange)

            if let emoji = emojis[replacementString.string.replacingOccurrences(of: ":", with: "")], let imageUrl = emoji.imageUrl {

                imageAttachment.contents = imageUrl.data(using: .utf8)
                let imageString = NSAttributedString(attachment: imageAttachment)
                string.replaceCharacters(in: transformedRange, with: imageString)

                offset += replacementString.length - 1
            } else {
                notMatched.append(transformedRange)
            }
        }

        return notMatched
    }

    static func getMatches(from string: NSMutableAttributedString, excludingRanges: [NSRange] = []) -> [NSRange] {
        var ranges = [NSRange]()
        var lastMatchIndex = 0
        for range in excludingRanges {
            ranges.append(NSRange(location: lastMatchIndex, length: range.location - lastMatchIndex + 1))
            lastMatchIndex = range.location + range.length - 1
        }
        ranges.append(NSRange(location: lastMatchIndex, length: string.length - lastMatchIndex))

        let regex = try? NSRegularExpression(pattern: ":(\\w|-|\\+)+:", options: [])
        let matchRanges = ranges.map { range in regex?.matches(in: string.string, options: [], range: range).map { $0.range(at: 0) } ?? [] }
        return matchRanges.reduce(into: [NSRange]()) { $0.append(contentsOf: $1) }
    }
}

extension String {
    func codeRanges() -> [NSRange] {
        let codeRegex = try? NSRegularExpression(pattern: "(```)(?:[a-zA-Z]+)?((?:.|\r|\n)*?)(```)", options: [.anchorsMatchLines])
        let codeMatches = codeRegex?.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) ?? []
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
}
