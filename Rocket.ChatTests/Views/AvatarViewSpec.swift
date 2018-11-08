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
    func testAvatarInitials() {
        let avatarView = AvatarView()

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
        XCTAssertTrue(avatarView.initialsFor("Foo.bar") == "FB")
        XCTAssertTrue(avatarView.initialsFor("Foobar.bar") == "FB")
        XCTAssertTrue(avatarView.initialsFor("Foobar.bar.zab") == "FZ")
        XCTAssertTrue(avatarView.initialsFor("...") == "?")
        XCTAssertTrue(avatarView.initialsFor(".foo.b.a") == "?")
        XCTAssertTrue(avatarView.initialsFor(".foo.b.a.") == "?")
        XCTAssertTrue(avatarView.initialsFor(".foo.b.a.") == "?")
        XCTAssertTrue(avatarView.initialsFor(".f.") == "?")
        XCTAssertTrue(avatarView.initialsFor(".f......") == "?")
        XCTAssertTrue(avatarView.initialsFor(".f......1234f") == "?")
        XCTAssertTrue(avatarView.initialsFor(".?.!\"") == "?")
        XCTAssertTrue(avatarView.initialsFor("1.2") == "12")
        XCTAssertTrue(avatarView.initialsFor("!.!") == "!!")
    }

    func testAvatarUpdatesFromImageURLChangesAvatarInitials() {
        let avatarView = AvatarView()

        guard let imageURL = URL(string: "http://foo.com") else {
            XCTAssert(false)
            return
        }

        avatarView.imageURL = imageURL
        avatarView.updateAvatar()
        XCTAssertEqual(avatarView.labelInitials.text, "?", "label text will be ?")
        XCTAssertEqual(avatarView.backgroundColor, .black, "background color is black")
    }

    func testAvatarUpdatesFromUserChanges() {
        let avatarView = AvatarView()

        let user = User()
        user.username = "foo.bar"

        avatarView.username = user.username
        XCTAssertEqual(avatarView.labelInitials.text, "FB", "label text will be FB")
        XCTAssertEqual(avatarView.backgroundColor, UIColor(hex: "#00BCD4"), "background color is not black")
    }

    func testAvatarUpdatesFromUserChangesEmptyUsername() {
        let avatarView = AvatarView()

        let user = User()

        avatarView.username = user.username
        XCTAssertEqual(avatarView.labelInitials.text, "?", "label text will be ?")
        XCTAssertEqual(avatarView.backgroundColor, .black, "background color is black")
    }

    func testUpdateFontSizeValidNumber() {
        let avatarView = AvatarView()

        avatarView.labelInitialsFontSize = 10
        XCTAssertEqual(avatarView.labelInitials.font.pointSize, 10, "label size will be changed")
    }

    func testUpdateFontSizeInvalidNumber() {
        let avatarView = AvatarView()

        avatarView.labelInitialsFontSize = nil
        XCTAssertEqual(avatarView.labelInitials.font.pointSize, 16, "label size will be the default")
    }

}
