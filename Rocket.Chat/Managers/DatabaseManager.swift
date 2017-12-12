//
//  DatabaseManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

struct DatabaseManager {

    /**
        - returns: The selected database index.
     */
    static var selectedIndex: Int {
        return UserDefaults.standard.value(forKey: ServerPersistKeys.selectedIndex) as? Int ?? 0
    }

    /**
        - returns: All servers stored locally into the app.
     */
    static var servers: [[String: String]]? {
        return UserDefaults.standard.value(forKey: ServerPersistKeys.servers) as? [[String: String]]
    }

    /**
        - parameter index: The database index user wants to select.
     */
    static func selectDatabase(at index: Int) {
        UserDefaults.standard.set(index, forKey: ServerPersistKeys.selectedIndex)
    }

    /**
        Remove selected server and select the
        first one.
     */
    static func removeSelectedDatabase() {
        removeDatabase(at: selectedIndex)
        selectDatabase(at: 0)
    }

    /**
        Copy a server information with a new URL
        and remove the old one.
    */
    static func copyServerInformation(from: Int, with newURL: String) -> Int {
        guard
            let servers = self.servers,
            servers.count > 0
        else {
            return -1
        }

        let selectedServer = servers[from]
        let newIndex = createNewDatabaseInstance(serverURL: newURL)

        if var servers = self.servers {
            var newServer = servers[newIndex]
            newServer[ServerPersistKeys.userId] = selectedServer[ServerPersistKeys.userId]
            newServer[ServerPersistKeys.token] = selectedServer[ServerPersistKeys.token]
            servers[newIndex] = newServer

            UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)

            removeDatabase(at: from)
        }

        return newIndex - 1
    }

    /**
        Removes server information at some index.
     
        parameter index: The database index user wants to delete.
     */
    static func removeDatabase(at index: Int) {
        if var servers = self.servers, servers.count > index {
            servers.remove(at: index)
            UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        }
    }

    /**
        This method cleans the servers that doesn't have
        authentication information.
     */
    static func cleanInvalidDatabases() {
        let servers = self.servers ?? []
        var validServers: [[String: String]] = []

        for server in servers {
            guard
                server[ServerPersistKeys.token] != nil,
                server[ServerPersistKeys.userId] != nil,
                server[ServerPersistKeys.databaseName] != nil,
                server[ServerPersistKeys.serverURL] != nil
            else {
                continue
            }

            validServers.append(server)
        }

        if selectedIndex > validServers.count - 1 {
            selectDatabase(at: 0)
        }

        UserDefaults.standard.set(validServers, forKey: ServerPersistKeys.servers)
    }

    /**
        This method will create a new database before user
        even authenticated into the server. This is used
        so we can populate the authentication information
        when user logins.
     
        - parameter serverURL: The server URL.
     */
    @discardableResult
    static func createNewDatabaseInstance(serverURL: String) -> Int {
        let defaults = UserDefaults.standard
        var servers = self.servers ?? []

        servers.append([
            ServerPersistKeys.databaseName: "\(String.random()).realm",
            ServerPersistKeys.serverURL: serverURL
        ])

        let index = servers.count - 1
        defaults.set(servers, forKey: ServerPersistKeys.servers)
        defaults.set(index, forKey: ServerPersistKeys.selectedIndex)
        return index
    }

    /**
        This method is responsible to get the server
        information that's stored locally on device and
        use it to change the database configuration being
        used by the currently instance.
 
        - parameter index: If the index you want to use isn't stored
            into the UserDefaults.standard, you can for the index
            using this parameter.
     */
    static func changeDatabaseInstance(index: Int? = nil) {
        guard
            let server = AuthManager.selectedServerInformation(index: index),
            let databaseName = server[ServerPersistKeys.databaseName]
        else {
            return
        }

        let configuration = Realm.Configuration(
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile(databaseName), isDirectory: false),
            deleteRealmIfMigrationNeeded: true
        )

        realmConfiguration = configuration
    }

    /**
     This method gets the realm associated with this server
    */
    static func databaseInstace(index: Int) -> Realm? {
        guard
            let server = AuthManager.selectedServerInformation(index: index),
            let databaseName = server[ServerPersistKeys.databaseName]
        else {
            return nil
        }

        let configuration = Realm.Configuration(
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile(databaseName), isDirectory: false),
            deleteRealmIfMigrationNeeded: true
        )

        return try? Realm(configuration: configuration)
    }
}

extension DatabaseManager {
    /**
     This method returns an index for the server with this URL if it already exists.
     - parameter serverUrl: The URL of the server
     */
    static func serverIndexForUrl(_ serverUrl: String) -> Int? {
        return servers?.index {
            $0[ServerPersistKeys.serverURL] == serverUrl
        }
    }
}
