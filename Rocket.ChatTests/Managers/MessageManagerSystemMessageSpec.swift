//
//  MessageManagerSystemMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

final class MessageManagerSystemMessageSpec: XCTestCase {

    func testSystemMessageCreationBasic() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        realm.execute({ realm in
            realm.add(subscription)
        })

        let messageIdentifier = "systemMessageBasic_1"
        let messageText = "Basic"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
            XCTAssertEqual(message?.text, messageText)
            XCTAssertEqual(message?.userIdentifier, "rocket.cat")
            XCTAssertNil(message?.avatar)
            XCTAssertTrue(message?.privateMessage ?? false)
        } else {
            XCTFail("basic object is not valid")
        }
    }

    func testSystemMessageCreationBasicWithAvatar() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        realm.execute({ realm in
            realm.add(subscription, update: true)
        })

        let messageIdentifier = "systemMessageBasic_2"
        let messageText = "Basic with Avatar"
        let avatarURL = "http://rocket.chat"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier,
            "avatar": avatarURL
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
            XCTAssertEqual(message?.text, messageText)
            XCTAssertEqual(message?.userIdentifier, "rocket.cat")
            XCTAssertEqual(message?.avatar, avatarURL)
            XCTAssertTrue(message?.privateMessage ?? false)
        } else {
            XCTFail("basic object is not valid")
        }
    }

    func testSystemMessageCreationWithCustomUser() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        let userIdentifier = "systemMessageUser_1"
        let user = User()
        user.identifier = userIdentifier
        user.username = userIdentifier

        realm.execute({ realm in
            realm.add(subscription, update: true)
        })

        let messageIdentifier = "systemMessageBasic_2"
        let messageText = "Basic with Avatar"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier,
            "u": ["_id": userIdentifier]
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
            XCTAssertEqual(message?.text, messageText)
            XCTAssertEqual(message?.userIdentifier, userIdentifier)
            XCTAssertTrue(message?.privateMessage ?? false)
        } else {
            XCTFail("basic object is not valid")
        }
    }

}
