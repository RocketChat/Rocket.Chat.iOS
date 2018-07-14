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

// MARK: Test Instance

extension AuthSettings {
    static func testInstance() -> AuthSettings {
        let settings = AuthSettings()
        settings.siteURL = "https://open.rocket.chat"
        settings.cdnPrefixURL = "https://open.rocket.chat"

        return settings
    }
}

class AuthSettingsSpec: XCTestCase {

    // MARK: Base URLs

    func testBaseURLsMappingNoSlashInTheEnd() {
        let json = JSON([[
            "_id": "Site_Url",
            "value": "https://foo.bar"
        ], [
            "_id": "CDN_PREFIX",
            "value": "https://cdn.foo.bar"
        ]])

        let settings = AuthSettings()
        settings.map(json, realm: nil)

        XCTAssertEqual(settings.siteURL, "https://foo.bar")
        XCTAssertEqual(settings.cdnPrefixURL, "https://cdn.foo.bar")
    }

    func testBaseURLsMappingWithSlashInTheEnd() {
        let json = JSON([[
            "_id": "Site_Url",
            "value": "https://foo.bar/"
        ], [
            "_id": "CDN_PREFIX",
            "value": "https://cdn.foo.bar/"
        ]])

        let settings = AuthSettings()
        settings.map(json, realm: nil)

        XCTAssertEqual(settings.siteURL, "https://foo.bar")
        XCTAssertEqual(settings.cdnPrefixURL, "https://cdn.foo.bar")
    }

    // MARK: Registration Form

    func testRegistrationFormPublic() {
        let authSettings = AuthSettings()
        authSettings.rawRegistrationForm = "Public"
        XCTAssertEqual(authSettings.registrationForm, .isPublic, "type is public for Public")
    }

    func testRegistrationFormDisabled() {
        let authSettings = AuthSettings()
        authSettings.rawRegistrationForm = "Disabled"
        XCTAssertEqual(authSettings.registrationForm, .isDisabled, "type is disabled for Disabled")
    }

    func testRegistrationFormSecretURL() {
        let authSettings = AuthSettings()
        authSettings.rawRegistrationForm = "Secret URL"
        XCTAssertEqual(authSettings.registrationForm, .isSecretURL, "type is secretURL for Secret URL")
    }

    func testRegistrationFormInvalid() {
        let authSettings = AuthSettings()
        authSettings.rawRegistrationForm = "Foobar"
        XCTAssertEqual(authSettings.registrationForm, .isPublic, "type is public for invalid")
    }

    // MARK: Custom Fields

    func testCustomFieldsCorrectJsonMapToArray() {
        let authSettings = AuthSettings()
        authSettings.rawCustomFields = jsonCustomFields()

        let customFields = authSettings.customFields

        XCTAssertEqual(customFields.count, 2, "will have correct custom fields")
    }

    private func jsonCustomFields() -> String {
        return "{ \"role\": {  \"type\": \"select\",  \"defaultValue\": \"student\",  \"options\": [\"teacher\", \"student\"],  \"required\": true, }, \"twitter\": {  \"type\": \"text\",  \"required\": true,  \"minLength\": 2,  \"maxLength\": 10 }}"
            .removingWhitespaces()
    }

    func testCustomFieldsBadJsonMapToEmptyArray() {
        let authSettings = AuthSettings()
        authSettings.rawCustomFields = ""

        let customFields = authSettings.customFields

        XCTAssert(customFields.isEmpty, "will have empty array of custom fields")
    }
}
