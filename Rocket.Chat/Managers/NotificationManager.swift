//
//  NotificationManager.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class NotificationManager {
    static let shared = NotificationManager()

    var notification: ChatNotification?

    /// Posts an in-app notification.
    ///
    /// **NOTE:** The notification is only posted if the `rid` of the
    /// notification is different from the `AppManager.currentRoomId`
    ///
    /// - parameters:
    ///     - notification: The `ChatNotification` object to display the
    ///         contents of the notification from. The `title` and the `body`
    ///         cannot be empty strings.

    static func post(notification: ChatNotification) {
        guard
            AppManager.currentRoomId != notification.payload.rid,
            !notification.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !notification.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        let formattedBody = NSMutableAttributedString(string: notification.body)
            .transformMarkdown().string
            .components(separatedBy: .newlines)
            .joined(separator: " ")
            .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)

        NotificationViewController.shared.displayNotification(
            title: notification.title,
            body: formattedBody,
            username: notification.payload.sender.username
        )

        NotificationManager.shared.notification = notification
    }

    func didRespondToNotification() {
        guard
            let notification = notification,
            let type = notification.payload.type
        else {
            return
        }

        switch type {
        case .channel:
            guard let name = notification.payload.name else { return }
            AppManager.openRoom(name: name)
        case .group:
            guard let name = notification.payload.name else { return }
            AppManager.openRoom(name: name, type: .group)
        case .directMessage:
            AppManager.openDirectMessage(username: notification.payload.sender.username)
        }
        self.notification = nil
    }
}
