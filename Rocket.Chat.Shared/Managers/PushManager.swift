//
//  PushManager.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class PushManager: SocketManagerInjected, AuthManagerInjected {

    let kDeviceTokenKey = "deviceToken"
    let kPushIdentifierKey = "pushIdentifier"

    var injectionContainer: InjectionContainer!

    func updatePushToken() {
        guard let deviceToken = getDeviceToken() else { return }
        guard let userIdentifier = authManager.isAuthenticated()?.userId else { return }

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
        ] as [String : Any]

        socketManager.send(request)
    }

    func updateUser(_ userIdentifier: String) {
        let request = [
            "msg": "method",
            "method": "raix:push-setuser",
            "userId": userIdentifier,
            "params": [getOrCreatePushId()]
        ] as [String : Any]

        socketManager.send(request)
    }

    fileprivate func getOrCreatePushId() -> String {
        guard let pushId = UserDefaults.standard.string(forKey: kPushIdentifierKey) else {
            let randomId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(randomId, forKey: kPushIdentifierKey)
            return randomId
        }

        return pushId
    }

    fileprivate func getDeviceToken() -> String? {
        guard let deviceToken = UserDefaults.standard.string(forKey: kDeviceTokenKey) else {
            return nil
        }

        return deviceToken
    }

}
