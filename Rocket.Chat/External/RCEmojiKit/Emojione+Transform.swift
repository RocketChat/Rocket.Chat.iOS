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

        let regex = try? NSRegularExpression(pattern: Emojione.regex, options: [])
        let ranges = regex?.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.count)
        ).map {
            $0.range(at: 0)
        } ?? []

        // exclude matches inside code tags
        let filteredRanges = string
            .filterOutRangesInsideCode(ranges: ranges)
            .reduce([(range: NSRange, length: Int)](), { total, current in
                // subtract previous ranges lengths from each range location, taking into account unicode length of emojis
                let shortname = String(_string.substring(with: current).dropFirst().dropLast())
                guard let emoji = (values[shortname] as NSString?) else { return total }
                let offset = total.reduce(0, { $0 + $1.range.length - $1.length })
                let range = NSRange(location: current.location - offset, length: current.length)
                return total + [(range: range, length: emoji.length)]
            }).map { $0.range }

        for range in filteredRanges {
            let shortname = String(_string.substring(with: range).dropFirst().dropLast())
            if let emoji = values[shortname] {
                _string = _string.replacingCharacters(in: range, with: emoji) as NSString
            }
        }

        return _string as String
    }
}
