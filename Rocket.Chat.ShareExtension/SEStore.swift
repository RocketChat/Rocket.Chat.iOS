//
//  Database.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

func fetchServers() -> [String] {
    return DatabaseManager.servers?.flatMap { $0[ServerPersistKeys.serverName] } ?? []
}

struct SEStore {
    let selectedServer: String = "open.rocket.chat"
}
