//
//  MessagesSizingViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Streit on 25/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import XCTest
@testable import Rocket_Chat

final class MessagesSizingViewModelSpec: XCTestCase {

    func testInitialState() {
        let model = MessagesSizingManager()
        XCTAssertEqual(model.cache.count, 0)
    }

    func testCacheHeightValue() {
        let model = MessagesSizingManager()
        let identifier = "identifier"
        model.set(size: CGSize(width: 0, height: 150), for: identifier)
        XCTAssertEqual(model.size(for: identifier)?.height, 150)
        XCTAssertEqual(model.cache.count, 1)
    }

    func testCacheNegativeValues() {
        let model = MessagesSizingManager()
        let identifier = "identifier"
        model.set(size: CGSize(width: 0, height: -1), for: identifier)
        XCTAssertNil(model.size(for: identifier))
        XCTAssertEqual(model.cache.count, 1)
    }

    func testCacheNotValidValues() {
        let model = MessagesSizingManager()
        let identifier = "identifier"
        model.set(size: CGSize(width: 0.0, height: Double.nan), for: identifier)
        XCTAssertNil(model.size(for: identifier))
        XCTAssertEqual(model.cache.count, 1)
    }

    func testClearCache() {
        let model = MessagesSizingManager()
        model.set(size: CGSize(width: 0, height: 150), for: "identifier.1")
        model.set(size: CGSize(width: 0, height: 175), for: "identifier.2")
        model.set(size: CGSize(width: 0, height: 200), for: "identifier.3")
        XCTAssertEqual(model.cache.count, 3)
        model.clearCache()
        XCTAssertEqual(model.cache.count, 0)
    }

}
