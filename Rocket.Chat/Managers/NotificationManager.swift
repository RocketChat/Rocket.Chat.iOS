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

    static func post(notification: ChatNotification) {
        guard AppManager.currentRoomId != notification.rid else { return }
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
