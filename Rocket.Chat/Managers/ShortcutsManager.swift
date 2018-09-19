//
//  ShortcutsManager.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 12.07.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

enum ShortcutItemType {
    case server(url: String, index: Int)
    case room(roomId: String, server: String, serverURL: String)
}

struct ShortcutItem {
    let name: String
    let type: ShortcutItemType
}

struct ShortcutsManager {
    static let addServerActionIdentifier = "addserver"
    static let connectServerNavIdentifier = "ConnectServerNav"
    static let serverIndexKey = "kServerIndex"
    static let serverUrlKey = "kServerURL"
    static let roomIdKey = "kRoomId"

    private static var shortcuts: [ShortcutItem]? {
        let servers = DatabaseManager.servers?.enumerated().compactMap({ index, server in
            ShortcutItem(
                name: server[ServerPersistKeys.serverName] ?? "",
                type: .server(
                    url: server[ServerPersistKeys.serverURL] ?? "",
                    index: index
                )
            )
        })

        guard
            servers?.count == 1,
            let server = servers?.first
        else {
            return servers
        }

        let serverURL: String?
        switch server.type {
        case .server(let url, _):
            serverURL = url
        default:
            serverURL = nil
        }

        guard let currentServerURL = serverURL else {
            return nil
        }

        // Rooms
        let subscriptions = Subscription.all()?.sortedByLastSeen()
        var rooms: [ShortcutItem]? = subscriptions?.compactMap({ room in
            ShortcutItem(
                name: room.displayName(),
                type: .room(
                    roomId: room.rid,
                    server: server.name,
                    serverURL: currentServerURL
                )
            )
        })

        return (rooms?.count ?? 0) > 5 ? Array(rooms?[..<4] ?? []) : rooms
    }

    static func sync() {
        UIApplication.shared.shortcutItems = shortcuts?.compactMap({ shortcut in
            let type: String
            let title: String
            let subtitle: String
            let userInfo: [String: NSSecureCoding]

            switch shortcut.type {
            case .server(let url, let index):
                type = URL(string: url)?.host ?? url
                title = shortcut.name
                subtitle = url
                userInfo = [serverIndexKey: index as NSSecureCoding]
            case .room(let roomId, let server, let serverURL):
                type = "\(serverURL)-\(shortcut.name)"
                title = shortcut.name
                subtitle = server
                userInfo = [roomIdKey: roomId as NSSecureCoding, serverUrlKey: serverURL as NSSecureCoding]
            }

            return UIMutableApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: subtitle, icon: nil, userInfo: userInfo)
        })
    }
}
