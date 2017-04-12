//
//  LoaderViewSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class LoaderViewSpec: XCTestCase {

    func testInitialization() {
        let view = LoaderView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        XCTAssertFalse(view.isHidden, "view is not hidden")
        XCTAssertFalse(view.isAnimating, "view is not animating")
        XCTAssertNil(view.layer.sublayers, "view doesn't contain sublayers yet")
    }

    func testStartAnimating() {
        let view = LoaderView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.startAnimating()

        XCTAssertFalse(view.isHidden, "view is not hidden")
        XCTAssertTrue(view.isAnimating, "view is animating")
        XCTAssertNotNil(view.layer.sublayers, "view contains sublayers")
        XCTAssertEqual(view.layer.sublayers?.count, 3, "view contains 3 sublayers")
    }

    func testStopAnimating() {
        let view = LoaderView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.startAnimating()
        view.stopAnimating()

        XCTAssertTrue(view.isHidden, "view is hidden")
        XCTAssertFalse(view.isAnimating, "view is not animating")
        XCTAssertNil(view.layer.sublayers, "view doesn't contains sublayers")
    }

}
