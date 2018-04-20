//
//  Emojione+Transform.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Emojione {

    static func transform(string: String) -> String {
        var validString = string as NSString
        var notMatched = [NSRange]()
        var ranges = getMatches(from: validString)

        (validString, notMatched) = insertEmojis(into: validString, in: (validString as String).filterOutRangesInsideCode(ranges: ranges))
        ranges = getMatches(from: validString, excludingRanges: notMatched)
        (validString, _) = insertEmojis(into: validString, in: (validString as String).filterOutRangesInsideCode(ranges: ranges))
        return validString as String
    }

    static func getMatches(from string: NSString, excludingRanges: [NSRange] = []) -> [NSRange] {
        var ranges = [NSRange]()
        var lastMatchIndex = 0
        for range in excludingRanges {
            ranges.append(NSRange(location: lastMatchIndex, length: range.location - lastMatchIndex + 1))
            lastMatchIndex = range.location + range.length - 1
        }
        ranges.append(NSRange(location: lastMatchIndex, length: string.length - lastMatchIndex))

        let regex = try? NSRegularExpression(pattern: ":(\\w|-|\\+)+:", options: [])
        let matchRanges = ranges.map { range in regex?.matches(in: string as String, options: [], range: range).map { $0.range(at: 0) } ?? [] }
        return matchRanges.reduce(into: [NSRange]()) { $0.append(contentsOf: $1) }
    }

    static func insertEmojis(into string: NSString, in ranges: [NSRange]) -> (string: NSString, notMatched: [NSRange]) {
        var offset = 0
        var string = string
        var notMatched = [NSRange]()

        for range in ranges {
            let transformedRange = NSRange(location: range.location - offset, length: range.length)
            let replacementString = string.substring(with: transformedRange) as NSString

            if let emoji = values[replacementString.replacingOccurrences(of: ":", with: "")] {
                string = string.replacingCharacters(in: transformedRange, with: emoji) as NSString
                offset += replacementString.length - (emoji as NSString).length
            } else {
                notMatched.append(transformedRange)
            }
        }

        return (string, notMatched)
    }
}
