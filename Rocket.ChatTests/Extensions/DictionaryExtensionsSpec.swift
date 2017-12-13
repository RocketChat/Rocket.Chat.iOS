//
//  DictionaryExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Vadym Brusko on 10/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class DictionaryExtensionsSpec: XCTestCase {

    func testInitWithKeyValuesPairs() {
        // arrange
        let pairs = [("key1", 1), ("key2", 2)]
        let expectedDictionary = ["key1": 1, "key2": 2]

        // act
        let resultDictionary = Dictionary(keyValuePairs: pairs)

        // assert
        XCTAssertEqual(resultDictionary, expectedDictionary, "init with keyValuesPairs create dictionary correctly")
    }

    func testUnionInPlaceUpdateAllKeys() {
        // arrange
        var originDictionary = ["key1": 1, "key2": 2]
        let additionDictionary = ["key1": 0, "key3": 3]
        let expectedDictionary = ["key1": 0, "key2": 2, "key3": 3]

        // act
        originDictionary.unionInPlace(dictionary: additionDictionary)

        // assert
        XCTAssertEqual(originDictionary, expectedDictionary, "unionInPlace update dictionary correctly")
    }

    func testUnionCreateUpdatedDictionary() {
        // arrange
        let originDictionary = ["key1": 1, "key2": 2]
        let additionDictionary = ["key1": 0, "key3": 3]
        let expectedDictionary = ["key1": 0, "key2": 2, "key3": 3]

        // act
        let newDictionary = additionDictionary.union(dictionary: originDictionary)

        // assert
        XCTAssertEqual(newDictionary, expectedDictionary, "union create updated dictionary correctly")
    }
}
