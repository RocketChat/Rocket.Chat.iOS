//
//  ChatNotification.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ChatNotification: Decodable, Equatable {
    var title: String
    var body: String
    var payload: Payload

    enum CodingKeys: String, CodingKey {
        case title
        case body = "text"
        case payload
    }
}

// swiftlint:disable nesting
extension ChatNotification {
    struct Payload: Codable, Equatable {
        var id: String
        var rid: String
        var name: String?
        var sender: Sender

        internal var internalType: String
        var type: SubscriptionType? {
            return SubscriptionType(rawValue: internalType)
        }
    }
}

extension ChatNotification.Payload {
    struct Sender: Codable, Equatable {
        let id: String
        let name: String?
        let username: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case username
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rid
        case name
        case sender
        case internalType = "type"
    }
}

extension ChatNotification {
    /// Posts an in-app notification.
    ///
    /// **NOTE:** The notification is only posted if the `rid` of the
    /// notification is different from the `AppManager.currentRoomId`

    func post() {
        NotificationManager.post(notification: self)
    }
}
