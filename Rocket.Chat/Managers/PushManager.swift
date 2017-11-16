//
//  PushManager.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import UserNotifications

final class PushManager {
    static let delegate = UserNotificationCenterDelegate()

    static let kDeviceTokenKey = "deviceToken"
    static let kPushIdentifierKey = "pushIdentifier"

    static var lastNotificationRoomId: String?

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

// MARK: Handle Notifications

struct PushNotification {

    let host: String
    let roomId: String

    init?(raw: [AnyHashable: Any]) {
        guard let _json = raw["ejson"] as? String else { return nil }
        let json = JSON(parseJSON: _json)

        guard
            let host = json["host"].string,
            let roomId = json["rid"].string
        else {
            return nil
        }

        self.host = host
        self.roomId = roomId
    }
}

extension PushManager {
    static func setupNotificationCenter(_ notificationCenter: UNUserNotificationCenter = .current()) {
        notificationCenter.delegate = PushManager.delegate
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
    }

    static func handleNotification(raw: [AnyHashable: Any]) -> Bool {
        guard let notification = PushNotification(raw: raw) else { return false }
        handleNotification(notification)
        return true
    }

    fileprivate static func hostToServerUrl(_ host: String) -> String? {
        return URL(string: host)?.socketURL()?.absoluteString
    }

    static func handleNotification(_ notification: PushNotification) {
        guard
            let serverUrl = hostToServerUrl(notification.host),
            let index = DatabaseManager.serverIndexForUrl(serverUrl)
        else {
            return
        }

        // side effect: needed for SubscriptionManager.initialSubscription() & .notificationSubscription()
        lastNotificationRoomId = notification.roomId

        if index != DatabaseManager.selectedIndex {
            AppManager.changeSelectedServer(index: index)
        } else {
            ChatViewController.shared?.subscription = SubscriptionManager.notificationSubscription()
        }
    }
}

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushManager.handleNotification(raw: response.notification.request.content.userInfo)
    }
}
