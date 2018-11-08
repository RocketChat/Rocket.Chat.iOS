//
//  CustomEmojiSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 1/4/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

extension CustomEmoji {
    static func testInstance() -> CustomEmoji {
        let json = JSON([
            "_id": "emoji-id",
            "name": "emoji-name",
            "aliases": [ "emoji-alias" ],
            "extension": "emoji-file-extension",
            "_updatedAt": [ "$date": 1480377601 ]
        ])

        let object = CustomEmoji()
        object.map(json, realm: nil)

        return object
    }
}

class CustomEmojiSpec: XCTestCase {
    func testMap() {
        let object = CustomEmoji.testInstance()

        XCTAssertNotNil(object.identifier)
        XCTAssertEqual(object.name, "emoji-name")
        XCTAssertEqual(object.aliases.count, 1)
        XCTAssertTrue(object.aliases.contains("emoji-alias"))
        XCTAssertEqual(object.ext, "emoji-file-extension")
    }

    func testImageUrl() {
        let object = CustomEmoji.testInstance()

        XCTAssertEqual(object.imageUrl(serverUrl: "https://open.rocket.chat"), "https://open.rocket.chat/emoji-custom/emoji-name.emoji-file-extension")
        XCTAssertEqual(object.imageUrl(serverUrl: nil), nil)
    }

    func testWithShortname() {
        let emojis = [CustomEmoji.testInstance(), CustomEmoji.testInstance(), CustomEmoji.testInstance()]
        emojis[0].identifier = "customemoji-0"
        emojis[1].identifier = "customemoji-1"
        emojis[2].identifier = "customemoji-2"

        emojis[0].name = "customemoji-0"
        emojis[1].name = "customemoji-1"
        emojis[2].name = "customemoji-2"

        emojis[0].aliases.append(objectsIn: ["ce0", "c0"])
        emojis[2].aliases.append(objectsIn: ["ce2"])

        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        realm.execute({ realm in
            realm.add(emojis)
        })

        XCTAssert(CustomEmoji.withShortname(":customemoji-0:", realm: realm) == emojis[0])
        XCTAssert(CustomEmoji.withShortname(":customemoji-1:", realm: realm) == emojis[1])
        XCTAssert(CustomEmoji.withShortname(":customemoji-2:", realm: realm) == emojis[2])
        XCTAssert(CustomEmoji.withShortname(":customemoji-3:", realm: realm) == nil)

        XCTAssert(CustomEmoji.withShortname(":ce0:", realm: realm) == emojis[0])
        XCTAssert(CustomEmoji.withShortname(":c0:", realm: realm) == emojis[0])
        XCTAssert(CustomEmoji.withShortname(":ce1:", realm: realm) == nil)
        XCTAssert(CustomEmoji.withShortname(":ce2:", realm: realm) == emojis[2])
        XCTAssert(CustomEmoji.withShortname(":ce3:", realm: realm) == nil)

        XCTAssert(CustomEmoji.withShortname("::", realm: realm) == nil)
    }
}
