//
//  DictionaryExtensions.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Dictionary {
    public init(keyValuePairs: [(Key, Value)]) {
        self.init()
        for pair in keyValuePairs {
            self[pair.0] = pair.1
        }
    }

    mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }

    func union(dictionary: Dictionary) -> Dictionary {
        var mutatingDictionary = dictionary
        mutatingDictionary.unionInPlace(dictionary: self)
        return mutatingDictionary
    }
}
