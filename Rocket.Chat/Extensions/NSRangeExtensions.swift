//
//  NSRangeExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16

        let lowerBound = lowerBound.samePosition(in: utf16)
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound)
        let length = utf16.distance(from: lowerBound, to: upperBound.samePosition(in: utf16))

        self.init(location: location, length: length)
    }

    public init(_ range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}
