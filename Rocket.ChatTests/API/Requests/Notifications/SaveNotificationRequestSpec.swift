//
//  SaveNotificationRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SaveNotificationRequestSpec: APITestCase {

    func testRequest() {
        let notificationPreferences = NotificationPreferences(desktopNotifications: .nothing,
                                                              disableNotifications: false,
                                                              emailNotifications: .nothing,
                                                              audioNotificationValue: .beep,
                                                              desktopNotificationDuration: 0,
                                                              audioNotifications: .nothing,
                                                              hideUnreadStatus: false,
                                                              mobilePushNotifications: .nothing)
        let preRequest = SaveNotificationRequest(rid: "5of4weEXaH7yncxz9", notificationPreferences: notificationPreferences)

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/rooms.saveNotification", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["notifications"]["disableNotifications"].string, notificationPreferences.disableNotifications ? "1" : "0", "disableNotifications is correct")
        XCTAssertEqual(bodyJson["notifications"]["emailNotifications"].string, notificationPreferences.emailNotifications.rawValue, "emailNotifications is correct")
        XCTAssertEqual(bodyJson["notifications"]["audioNotifications"].string, notificationPreferences.audioNotifications.rawValue, "audioNotifications is correct")
        XCTAssertEqual(bodyJson["notifications"]["mobilePushNotifications"].string, notificationPreferences.mobilePushNotifications.rawValue, "mobilePushNotifications is correct")
        XCTAssertEqual(bodyJson["notifications"]["audioNotificationValue"].string, notificationPreferences.audioNotificationValue.rawValue, "audioNotificationValue is correct")
        XCTAssertEqual(bodyJson["notifications"]["desktopNotificationDuration"].string, String(notificationPreferences.desktopNotificationDuration), "desktopNotificationDuration is correct")
        XCTAssertEqual(bodyJson["notifications"]["hideUnreadStatus"].string, notificationPreferences.hideUnreadStatus ? "1" : "0", "hideUnreadStatus is correct")
    }

    func testResult() {
        let jsonString = """
        {
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = UpdateUserResource(raw: json)
        XCTAssertTrue(result.success)
    }

}
