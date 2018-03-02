//
//  ServerManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/07/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class ServerManager {

    static let shared = ServerManager()
    var timestampOffset = 0.0

    /**
        This method will get the selected database information
        locally and update a few settings that are important to
        keep save locally even when database doesn't exist.
     
        - parameter settings: The AuthSettings instance that
            have information required.
     */
    static func updateServerInformation(from settings: AuthSettings) {
        let defaults = UserDefaults.group
        let selectedIndex = DatabaseManager.selectedIndex

        guard
            let serverName = settings.serverName,
            let iconURL = settings.serverFaviconURL,
            var servers = DatabaseManager.servers,
            servers.count > selectedIndex
        else {
            return
        }

        servers[selectedIndex][ServerPersistKeys.serverName] = serverName
        servers[selectedIndex][ServerPersistKeys.serverIconURL] = iconURL

        defaults.set(servers, forKey: ServerPersistKeys.servers)
    }

    /**
        This method is suppose to be executed only once per server
        connection. It gets the server timestamp and syncs to the
        timestamp of the user that's using the app.
     */
    static func timestampSync() {
        guard
            let auth = AuthManager.isAuthenticated(),
            let serverURL = URL(string: auth.serverURL),
            let url = serverURL.timestampURL()
        else {
            return
        }

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
