//
//  PushManager.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

/// A manager that manages all push notifications related actions
public class PushManager: SocketManagerInjected, AuthManagerInjected {

    let kDeviceTokenKey = "deviceToken"
    let kPushIdentifierKey = "pushIdentifier"

    var injectionContainer: InjectionContainer!

    func updatePushToken() {
        guard let deviceToken = getDeviceToken() else { return }
        updatePushToken(with: deviceToken, pushId: getOrCreatePushId())
    }

    /// Update server's memories of current user's device token
    ///
    /// - Parameters:
    ///   - deviceToken: new device token
    ///   - pushId: push id
    public func updatePushToken(with deviceToken: String, pushId: String) {
        guard let userIdentifier = authManager.isAuthenticated()?.userId else { return }

        let request = [
            "msg": "method",
            "method": "raix:push-update",
            "params": [[
                "id": pushId,
                "userId": userIdentifier,
                "token": ["apn": deviceToken],
                "appName": Bundle.main.bundleIdentifier ?? "main",
                "metadata": [:]
                ]]
            ] as [String : Any]

        socketManager.send(request)
    }

    /// Update server's memories of current user's push id
    public func updateUser() {
        guard let userIdentifier = authManager.isAuthenticated()?.userId else { return }
        updateUser(userIdentifier, pushId: getOrCreatePushId())
    }

    /// Update server's memories of given user's push id with given push id
    ///
    /// - Parameters:
    ///   - userIdentifier: user's id
    ///   - pushId: push id
    public func updateUser(_ userIdentifier: String, pushId: String) {
        let request = [
            "msg": "method",
            "method": "raix:push-setuser",
            "userId": userIdentifier,
            "params": [pushId]
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
