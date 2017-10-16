//
//  PushManager.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class PushManager {

    static let kDeviceTokenKey = "deviceToken"
    static let kPushIdentifierKey = "pushIdentifier"

    static func updatePushToken() {
        guard let deviceToken = getDeviceToken() else { return }
        guard let userIdentifier = AuthManager.isAuthenticated()?.userId else { return }

        let request = [
            "msg": "method",
            "method": "raix:push-update",
            "params": [[
                "id": getOrCreatePushId(),
                "userId": userIdentifier,
                "token": ["apn": deviceToken],
                "appName": Bundle.main.bundleIdentifier ?? "main",
                "metadata": [:]
            ]]
        ] as [String: Any]

        SocketManager.send(request)
    }

    static func updateUser(_ userIdentifier: String) {
        let request = [
            "msg": "method",
            "method": "raix:push-setuser",
            "userId": userIdentifier,
            "params": [getOrCreatePushId()]
        ] as [String: Any]

        SocketManager.send(request)
    }

    fileprivate static func getOrCreatePushId() -> String {
        guard let pushId = UserDefaults.standard.string(forKey: kPushIdentifierKey) else {
            let randomId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(randomId, forKey: kPushIdentifierKey)
            return randomId
        }

        return pushId
    }

    fileprivate static func getDeviceToken() -> String? {
        guard let deviceToken = UserDefaults.standard.string(forKey: kDeviceTokenKey) else {
            return nil
        }

        return deviceToken
    }

}
