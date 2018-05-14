//
//  DrawingViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 13.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class DrawingViewModelSpec: XCTestCase {
    let model = DrawingViewModel()

    func testModelOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotNil(model.errorTitle)
        XCTAssertNotNil(model.errorMessage)
    }
}
