//
//  NotificationManager.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class NotificationManager {
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
        guard AppManager.currentRoomId != notification.rid else { return }
        guard !notification.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !notification.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        NotificationViewController.shared.displayNotification(title: notification.title, body: notification.body, username: notification.sender.username)
        NotificationManager.shared.notification = notification
    }

    func didRespondToNotification() {
        guard let notification = notification else { return }
        switch notification.type {
        case .channel(let name): AppManager.openChannel(name: name)
        case .direct(let sender): AppManager.openDirectMessage(username: sender.username)
        }
        self.notification = nil
    }
}
