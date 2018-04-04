//
//  MentionsTextFieldTableViewCellSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 25.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class MentionsTextFieldTableViewCellSpec: XCTestCase {
    func testInitializeFromNib() {
        XCTAssertNotNil(MentionsTextFieldTableViewCell.instantiateFromNib(), "instantiation from nib will work")
    }

    func testInitials() {
        guard let cell = MentionsTextFieldTableViewCell.instantiateFromNib() else {
            XCTAssert(false)
            return
        }

        cell.awakeFromNib()
        XCTAssertTrue(cell.textFieldInput.clearButtonMode == .whileEditing, "incorrect clearButtonMode")
    }
}
