//
//  EditProfileViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 23/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class EditProfileViewModelSpec: XCTestCase {

    let model = EditProfileViewModel()

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.editingTitle)
        XCTAssertNotEqual(model.editingTitle, "")

        XCTAssertNotNil(model.saveButtonTitle)
        XCTAssertNotEqual(model.saveButtonTitle, "")

        XCTAssertNotNil(model.editButtonTitle)
        XCTAssertNotEqual(model.editButtonTitle, "")

        XCTAssertNotNil(model.profileSectionTitle)
        XCTAssertNotEqual(model.profileSectionTitle, "")

        XCTAssertNotNil(model.namePlaceholder)
        XCTAssertNotEqual(model.namePlaceholder, "")

        XCTAssertNotNil(model.usernamePlaceholder)
        XCTAssertNotEqual(model.usernamePlaceholder, "")

        XCTAssertNotNil(model.emailPlaceholder)
        XCTAssertNotEqual(model.emailPlaceholder, "")

        XCTAssertNotNil(model.changeYourPasswordTitle)
        XCTAssertNotEqual(model.changeYourPasswordTitle, "")
    }

}
