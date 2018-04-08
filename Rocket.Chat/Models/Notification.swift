//
//  Notification.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ChatNotification {
    let sender: Sender
    let type: NotificationType
    let title: String
    let body: String
    let rid: String
}

extension ChatNotification {
    // swiftlint:disable nesting
    struct Sender: Codable {
        let name: String
        let username: String
        let id: String

        enum CodingKeys: String, CodingKey {
            case name
            case username
            case id = "_id"
        }
    }

    enum NotificationType {
        case channel(String)
        case direct(Sender)
    }
}

extension ChatNotification: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case body = "text"
        case payload
    }

    enum PayloadKeys: String, CodingKey {
        case sender
        case channel = "name"
        case type
        case rid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body).trimmingCharacters(in: .newlines)
        let payload = try container.nestedContainer(keyedBy: PayloadKeys.self, forKey: .payload)
        self.sender = try payload.decode(Sender.self, forKey: .sender)
        self.rid = try payload.decode(String.self, forKey: .rid)
        self.type = try ChatNotification.notificationType(from: payload)
    }

    static func notificationType(from container: KeyedDecodingContainer<ChatNotification.PayloadKeys>) throws -> NotificationType {
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "d":
            let sender = try container.decode(Sender.self, forKey: .sender)
            return .direct(sender)
        case "c":
            let channel = try container.decode(String.self, forKey: .channel)
            return .channel(channel)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [PayloadKeys.type], debugDescription: "Type of notification not supported"))
        }
    }
}

extension ChatNotification {
    func post() {
        NotificationManager.post(notification: self)
    }
}
