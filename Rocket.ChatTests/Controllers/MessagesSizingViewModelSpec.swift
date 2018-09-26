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
        let model = MessagesSizingViewModel()
        XCTAssertEqual(model.cache.count, 0)
    }

    func testCacheHeightValue() {
        let model = MessagesSizingViewModel()
        let identifier = "identifier"
        model.set(height: CGFloat(150.0), for: identifier)
        XCTAssertEqual(model.height(for: identifier), CGFloat(150.0))
        XCTAssertEqual(model.cache.count, 1)
    }

    func testClearCache() {
        let model = MessagesSizingViewModel()
        model.set(height: CGFloat(150.0), for: "identifier.1")
        model.set(height: CGFloat(175.0), for: "identifier.2")
        model.set(height: CGFloat(200.0), for: "identifier.3")
        XCTAssertEqual(model.cache.count, 3)
        model.clearCache()
        XCTAssertEqual(model.cache.count, 0)
    }

}
