//
//  SaveNotificationRequest.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

final class SaveNotificationRequest: APIRequest {
    typealias APIResourceType = SaveNotificationResource

    let requiredVersion = Version(0, 63, 0)
    let method: HTTPMethod = .post
    let path = "/api/v1/rooms.saveNotification"

    let rid: String
    let notificationPreferences: NotificationPreferences

    init(rid: String, notificationPreferences: NotificationPreferences) {
        self.rid = rid
        self.notificationPreferences = notificationPreferences
    }

    func body() -> Data? {
        var body = JSON([
            "roomId": rid,
            "notifications": [:]
            ])

        body["notifications"]["disableNotifications"].string = notificationPreferences.disableNotifications ? "1" : "0"
        body["notifications"]["emailNotifications"].string = notificationPreferences.emailNotifications.rawValue
        body["notifications"]["audioNotifications"].string = notificationPreferences.audioNotifications.rawValue
        body["notifications"]["mobilePushNotifications"].string = notificationPreferences.mobilePushNotifications.rawValue
        body["notifications"]["audioNotificationValue"].string = notificationPreferences.audioNotificationValue.rawValue
        body["notifications"]["desktopNotificationDuration"].string = String(notificationPreferences.desktopNotificationDuration)
        body["notifications"]["hideUnreadStatus"].string = notificationPreferences.hideUnreadStatus ? "1" : "0"

        let string = body.rawString()
        let data = string?.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "application/json"
    }
}

final class SaveNotificationResource: APIResource {
    var success: Bool {
        return raw?["success"].boolValue ?? false
    }

    var errorMessage: String? {
        return raw?["error"].string
    }
}
