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
        guard let pushId = UserDefaults.group.string(forKey: kPushIdentifierKey) else {
            let randomId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            UserDefaults.group.set(randomId, forKey: kPushIdentifierKey)
            return randomId
        }

        return pushId
    }

    static func getDeviceToken() -> String? {
        guard let deviceToken = UserDefaults.group.string(forKey: kDeviceTokenKey) else {
            return nil
        }

        return deviceToken
    }

}

// MARK: Handle Notifications

struct PushNotification {
    let host: String
    let username: String
    let roomId: String
    let roomType: SubscriptionType

    init?(raw: [AnyHashable: Any]) {
        guard
            let json = JSON(parseJSON: (raw["ejson"] as? String) ?? "").dictionary,
            let host = json["host"]?.string,
            let username = json["sender"]?["username"].string,
            let roomType = json["type"]?.string,
            let roomId = json["rid"]?.string
        else {
            return nil
        }

        self.host = host
        self.username = username
        self.roomId = roomId
        self.roomType = SubscriptionType(rawValue: roomType) ?? .group
    }
}

// MARK: Categories

extension UNNotificationAction {
    static var reply: UNNotificationAction {
        return UNTextInputNotificationAction(
            identifier: "REPLY",
            title: localized("notifications.action.reply"),
            options: .authenticationRequired
        )
    }
}

extension UNNotificationCategory {
    static var message: UNNotificationCategory {
        return UNNotificationCategory(
            identifier: "MESSAGE",
            actions: [.reply],
            intentIdentifiers: [],
            options: []
        )
    }

    static var messageNoReply: UNNotificationCategory {
        return UNNotificationCategory(
            identifier: "REPLY",
            actions: [.reply],
            intentIdentifiers: [],
            options: []
        )
    }
}

extension PushManager {
    static func setupNotificationCenter() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = PushManager.delegate
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        notificationCenter.setNotificationCategories([.message, .messageNoReply])
    }

    @discardableResult
    static func handleNotification(raw: [AnyHashable: Any], reply: String? = nil) -> Bool {
        guard let notification = PushNotification(raw: raw) else { return false }
        return handleNotification(notification, reply: reply)
    }

    @discardableResult
    static func handleNotification(_ notification: PushNotification, reply: String? = nil) -> Bool {
        guard
            let serverUrl = URL(string: notification.host)?.socketURL()?.absoluteString,
            let index = DatabaseManager.serverIndexForUrl(serverUrl)
        else {
            return false
        }

        // side effect: needed for Subscription.notificationSubscription()
        AppManager.initialRoomId = notification.roomId

        if index != DatabaseManager.selectedIndex {
            AppManager.changeSelectedServer(index: index)
        } else {
            ChatViewController.shared?.subscription = .notificationSubscription()
        }

        if let reply = reply {
            let appendage = notification.roomType == .directMessage ? "" : " @\(notification.username)"

            let message = "\(reply)\(appendage)"

            let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            API.current()?.fetch(PostMessageRequest(roomId: notification.roomId, text: message), succeeded: { _ in
                UIApplication.shared.endBackgroundTask(backgroundTask)
            }, errored: { _ in
                // TODO: Handle error
            })
        }

        return true
    }
}

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushManager.handleNotification(
            raw: response.notification.request.content.userInfo,
            reply: (response as? UNTextInputNotificationResponse)?.userText
        )
    }
}
