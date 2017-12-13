//
//  TextFieldSpec.swift
//  Rocket.ChatTests
//
//  Created by Vadym Brusko on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class TextFieldSpec: XCTestCase {
    func testMap() {
        // arrange
        let textField = TextField()
        let minLength = -5
        let maxLength = 5
        let json = JSON([
            "minLength": minLength,
            "maxLength": maxLength
        ])

        // act
        textField.map(json, realm: nil)

        // assert
        XCTAssertEqual(textField.minLength, minLength, "will have minLength")
        XCTAssertEqual(textField.maxLength, maxLength, "will have maxLength")
    }
}
