//
//  ShortcutsManager.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 12.07.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct ShortcutServerItem {
    let name: String
    let url: String
    let index: Int
}

struct ShortcutsManager {
    static let serverIndex = "kServerIndex"

    private static var shortcuts: [ShortcutServerItem]? {
        let servers = DatabaseManager.servers?.enumerated().compactMap({ index, server in
            ShortcutServerItem(name: server[ServerPersistKeys.serverName] ?? "", url: server[ServerPersistKeys.serverURL] ?? "", index: index)
        })

        return servers
    }

    static func sync() {
        UIApplication.shared.shortcutItems = shortcuts?.compactMap({ shortcut in
            let url = URL(string: shortcut.url)?.host ?? shortcut.url
            return UIMutableApplicationShortcutItem(type: url, localizedTitle: shortcut.name, localizedSubtitle: url, icon: nil, userInfo: [serverIndex: shortcut.index])
        })
    }

    static func selectServer(at index: Int) {
        guard index != DatabaseManager.selectedIndex else {
            return
        }

        DatabaseManager.selectDatabase(at: index)
        DatabaseManager.changeDatabaseInstance(index: index)

        SocketManager.disconnect { (_, _) in
            WindowManager.open(.subscriptions)
        }

        AppManager.changeSelectedServer(index: index)
    }
}
