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
        var _string = string as NSString

        let regex = try? NSRegularExpression(pattern: ":(\\w+|-|\\+)*:", options: [])
        let ranges = regex?.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.count)
        ).map {
            $0.range(at: 0)
        } ?? []

        // exclude matches inside code tags
        let filteredRanges = string.filterOutRangesInsideCode(ranges: ranges)

        var offset = 0
        for range in filteredRanges {
            let transformedRange = NSRange(location: range.location - offset, length: range.length)
            let replacementString = _string.substring(with: transformedRange) as NSString

            if let emoji = values[replacementString.replacingOccurrences(of: ":", with: "")] {
                _string = _string.replacingCharacters(in: transformedRange, with: emoji) as NSString
                offset += replacementString.length - (emoji as NSString).length
            }
        }

        return _string as String
    }
}
