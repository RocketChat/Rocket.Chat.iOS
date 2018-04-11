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

extension ChatNotification {
    // swiftlint:disable nesting
    struct Sender: Codable, Equatable {
        let name: String
        let username: String
        let id: String

        enum CodingKeys: String, CodingKey {
            case name
            case username
            case id = "_id"
        }
    }

    typealias ChannelName = String

    enum NotificationType: Equatable {
        case channel(ChannelName)
        case group(ChannelName)
        case direct(Sender)
    }

    struct Payload: Equatable {
        var sender: Sender
        var type: NotificationType
        var rid: String

        enum CodingKeys: String, CodingKey {
            case sender
            case channelName = "name"
            case type
            case rid
        }
    }
}

extension ChatNotification.Payload: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sender = try container.decode(ChatNotification.Sender.self, forKey: .sender)
        self.rid = try container.decode(String.self, forKey: .rid)
        self.type = try ChatNotification.Payload.notificationType(from: container)
    }

    static func notificationType(from container: KeyedDecodingContainer<CodingKeys>) throws -> ChatNotification.NotificationType {
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "d":
            let sender = try container.decode(ChatNotification.Sender.self, forKey: .sender)
            return .direct(sender)
        case "c":
            let channel = try container.decode(String.self, forKey: .channelName)
            return .channel(channel)
        case "p":
            let group = try container.decode(String.self, forKey: .channelName)
            return .group(group)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Type of notification not supported"))
        }
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
