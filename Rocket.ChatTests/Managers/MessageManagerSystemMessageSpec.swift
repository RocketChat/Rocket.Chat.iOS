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

final class MessageManagerSystemMessageSpec: RealmTestCase {

    func testSystemMessageCreationBasic() {
        let realm = testRealm()

        let messageIdentifier = "systemMessageBasic_1"
        let messageText = "Basic"

        if let basicObject = ["_id": messageIdentifier, "msg": messageText, "attachments": []] as? [String: JSON] {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
            XCTAssertEqual(message?.text, messageText)
            XCTAssertTrue(message?.privateMessage ?? false)
        } else {
            XCTFail("message object wasn't created")
        }

    }

}
