//
//  MessageURLSpec.swift
//  Rocket.Chat
//
//  Created by TanakaJun on 2017/05/27.
//  Copyright © 2017年 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

extension MessageURL {

    static func testInstance() -> MessageURL {
        let messageURL = MessageURL()
        messageURL.targetURL = "http://www.rocket.chat"
        messageURL.title = "title"
        messageURL.textDescription = "description"
        messageURL.imageURL = "http://qux.quux.corge"
        return messageURL
    }

}

class MessageURLSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })

    }

    func testMessageURLObject() {
        let object = MessageURL.testInstance()

        Realm.execute({ realm in
            realm.add(object)
            let results = realm.objects(MessageURL.self)
            let first = results.first
            XCTAssert(results.count == 1, "MessageURL object was created with success")
            XCTAssert(first?.title == "title", "MessageURL object was created with success")
        })
    }

    func testIsValidWithValidAttributes() {
        let object = MessageURL.testInstance()
        XCTAssertTrue(object.isValid())
    }

    func testIsValidWithInvalidAttributes() {
        let object = MessageURL.testInstance()
        object.textDescription = ""
        XCTAssertFalse(object.isValid())
    }

    func testIsValidWithNilTitle() {
        let object = MessageURL.testInstance()
        object.title = nil
        XCTAssertFalse(object.isValid())
    }

    func testIsValidWithNilDescription() {
        let object = MessageURL.testInstance()
        object.textDescription = nil
        XCTAssertFalse(object.isValid())
    }

}
