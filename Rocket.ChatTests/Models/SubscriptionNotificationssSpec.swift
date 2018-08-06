//
//  SubscriptionNotificationssSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 18.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

extension SubscriptionSpec {
    func testNotifications() {
        let object = JSON([
            "disableNotifications": false,
            "hideUnreadStatus": true,
            "desktopNotifications": "all",
            "emailNotifications": "nothing",
            "audioNotificationValue": "beep",
            "desktopNotificationDuration": 2,
            "audioNotifications": "all",
            "mobilePushNotifications": "mentions"
            ])

        let subscription = Subscription()

        subscription.mapNotifications(object)

        XCTAssertFalse(subscription.disableNotifications)
        XCTAssertTrue(subscription.hideUnreadStatus)
        XCTAssertEqual(subscription.desktopNotifications, .all)
        XCTAssertEqual(subscription.audioNotifications, .all)
        XCTAssertEqual(subscription.mobilePushNotifications, .mentions)
        XCTAssertEqual(subscription.emailNotifications, .nothing)
        XCTAssertEqual(subscription.audioNotificationValue, .beep)
        XCTAssertEqual(subscription.desktopNotificationDuration, 2)
    }
}
