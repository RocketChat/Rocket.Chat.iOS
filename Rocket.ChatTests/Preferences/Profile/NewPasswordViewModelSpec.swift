//
//  NewPasswordViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 23/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NewPasswordViewModelSpec: XCTestCase {

    let model = NewPasswordViewModel()

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.saveButtonTitle)
        XCTAssertNotEqual(model.saveButtonTitle, "")

        XCTAssertNotNil(model.passwordSectionTitle)
        XCTAssertNotEqual(model.passwordSectionTitle, "")

        XCTAssertNotNil(model.passwordPlaceholder)
        XCTAssertNotEqual(model.passwordPlaceholder, "")

        XCTAssertNotNil(model.passwordConfirmationPlaceholder)
        XCTAssertNotEqual(model.passwordConfirmationPlaceholder, "")
    }

}
