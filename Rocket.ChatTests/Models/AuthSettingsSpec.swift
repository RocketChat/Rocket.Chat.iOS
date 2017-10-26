//
//  AuthSettingsSpec.swift
//  Rocket.ChatTests
//
//  Created by Vadym Brusko on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class AuthSettingsModelMappingSpec: XCTestCase {
    func testCustomFieldsCorrectJsonMapToArray() {
        // arrange
        let authSettings = AuthSettings()
        authSettings.rawCustomFields = jsonCustomFields()

        // act
        let customFields = authSettings.customFields

        // assert
        XCTAssertEqual(customFields.count, 2, "will have correct custom fields")
    }

    private func jsonCustomFields() -> String {
        return "{ \"role\": {  \"type\": \"select\",  \"defaultValue\": \"student\",  \"options\": [\"teacher\", \"student\"],  \"required\": true, }, \"twitter\": {  \"type\": \"text\",  \"required\": true,  \"minLength\": 2,  \"maxLength\": 10 }}"
            .removingWhitespaces()
    }

    func testCustomFieldsBadJsonMapToEmptyArray() {
        // arrange
        let authSettings = AuthSettings()
        authSettings.rawCustomFields = ""

        // act
        let customFields = authSettings.customFields

        // assert
        XCTAssert(customFields.isEmpty, "will have empty array of custom fields")
    }
}
