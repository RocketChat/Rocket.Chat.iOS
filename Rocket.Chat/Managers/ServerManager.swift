//
//  ServerManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/07/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ServerPersistKeys {
    // Server controls
    static let servers = "kServers"
    static let selectedIndex = "kSelectedIndex"

    // Database
    static let databaseName = "kDatabaseName"

    // Authentication information
    static let token = "kAuthToken"
    static let serverURL = "kAuthServerURL"
    static let userId = "kUserId"

    // Display information
    static let serverIconURL = "kServerIconURL"
    static let serverName = "kServerName"
}

class ServerManager {

    static let shared = ServerManager()
    var timestampOffset = 0.0

    static func updateServerInformation(from settings: AuthSettings) {
        let defaults = UserDefaults.standard

        guard
            let serverName = settings.serverName,
            let iconURL = settings.serverFaviconURL,
            let selectedIndex = DatabaseManager.selectedIndex,
            var servers = DatabaseManager.servers,
            servers.count > selectedIndex
            else {
                return
        }

        servers[selectedIndex][ServerPersistKeys.serverName] = serverName
        servers[selectedIndex][ServerPersistKeys.serverIconURL] = iconURL

        defaults.set(servers, forKey: ServerPersistKeys.servers)
    }

    static func timestampSync() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let serverURL = URL(string: auth.serverURL) else { return }
        guard let url = serverURL.timestampURL() else { return }

        let request = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { (data, _, _) in
            if let data = data {
                if let timestamp = String(data: data, encoding: .utf8) {
                    if let timestampDouble = Double(timestamp) {
                        ServerManager.shared.timestampOffset = Date().timeIntervalSince1970 * 1000 - timestampDouble
                    }
                }
            }
        })

        task.resume()
    }

}
