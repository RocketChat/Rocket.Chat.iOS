//
//  DrawingBrushColorSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 13.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class DrawingBrushColorSpec: XCTestCase {
    let model = DrawingBrushColorViewModel()

    func testIfModelHasEnoughData() {
        XCTAssertNotNil(model.cellIdentifier)
        XCTAssertTrue(model.availableColors.count > 0)
        XCTAssertNotNil(model.selectedColorLabel)
        XCTAssertNotNil(model.othersLabel)
    }
}
