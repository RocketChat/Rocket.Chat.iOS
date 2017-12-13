//
//  CustomFieldsSpec.swift
//  Rocket.ChatTests
//
//  Created by Vadym Brusko on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class CustomFieldsSpec: XCTestCase {
    func testMap() {
        // arrage
        let customField = CustomField()
        let json = JSON(["required": true])

        // act
        customField.map(json, realm: nil)

        // assert
        XCTAssertEqual(customField.required, true, "will have required")
    }

    func testChooseTypeSelect() {
        XCTAssert(create(type: SelectField.type) is SelectField, "select type was detected correctly")
    }

    func testChooseTypeText() {
        XCTAssert(create(type: TextField.type) is TextField, " texttype was detected correctly")
    }

    private func create(type: String) -> CustomField {
        let json = JSON(["type": type])
        return CustomField.chooseType(from: json, name: "")
    }
}
