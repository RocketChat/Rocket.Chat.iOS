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
        let object = MessageURL()

        object.identifier = "123"
        object.title = "Foo Bar Baz"
        object.textDescription = "foobarbaz"
        object.targetURL =  "http://foo.bar.baz"
        object.imageURL = "http://qux.quux.corge"

        Realm.execute({ realm in
            realm.add(object, update: true)
            let results = realm.objects(MessageURL.self)
            let first = results.first
            XCTAssert(results.count == 1, "MessageURL object was created with success")
            XCTAssert(first?.identifier == "123", "MessageURL object was created with success")
        })
    }

    func testIsValidWithValidAttributes() {

        let object = MessageURL()

        object.identifier = "123"
        object.title = "Foo Bar Baz"
        object.textDescription = "foobarbaz"

        XCTAssertTrue(object.isValid())
    }

    func testIsValidWithInvalidAttributes() {

        let object = MessageURL()

        object.identifier = "123"
        object.title = ""
        object.textDescription = "foobarbaz"

        XCTAssertFalse(object.isValid())
    }
}
