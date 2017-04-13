//
//  AvatarViewSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AvatarViewSpec: XCTestCase {

    func testInitializeFromNib() {
        XCTAssertNotNil(AvatarView.instantiateFromNib(), "instantiation from nib will work")
    }

    func testAvatarInitials() {
        guard let avatarView = AvatarView.instantiateFromNib() else {
            XCTAssert(false)
            return
        }

        XCTAssertTrue(avatarView.initialsFor("") == "?")
        XCTAssertTrue(avatarView.initialsFor("?") == "?")
        XCTAssertTrue(avatarView.initialsFor("f") == "F")
        XCTAssertTrue(avatarView.initialsFor("B") == "B")
        XCTAssertTrue(avatarView.initialsFor("fo") == "FO")
        XCTAssertTrue(avatarView.initialsFor("FO") == "FO")
        XCTAssertTrue(avatarView.initialsFor("fOo") == "FO")
        XCTAssertTrue(avatarView.initialsFor("FOO") == "FO")
        XCTAssertTrue(avatarView.initialsFor("F.O") == "FO")
        XCTAssertTrue(avatarView.initialsFor("F.o") == "FO")
        XCTAssertTrue(avatarView.initialsFor("F.o") == "FO")
        XCTAssertTrue(avatarView.initialsFor("Foo.bar") == "FB")
        XCTAssertTrue(avatarView.initialsFor("Foobar.bar") == "FB")
        XCTAssertTrue(avatarView.initialsFor("Foobar.bar.zab") == "FZ")
    }

}
