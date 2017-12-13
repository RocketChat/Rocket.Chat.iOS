//
//  SelectFieldSpec.swift
//  Rocket.ChatTests
//
//  Created by Vadym Brusko on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SelectFieldSpec: XCTestCase {
    func testMap() {
        // arrange
        let selectField = SelectField()
        let options = ["teacher", "student"]
        let defaultValue = "teacher"
        let json = JSON([
            "options": options,
            "defaultValue": defaultValue
        ])

        // act
        selectField.map(json, realm: nil)

        // assert
        XCTAssertEqual(selectField.options, options, "will have options")
        XCTAssertEqual(selectField.defaultValue, defaultValue, "will have defaultValue")
    }
}
