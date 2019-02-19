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

/**
 This keys are used to store all servers and
 database information to each server user is
 connected to.
 */
struct ServerPersistKeys {
    // Server controls
    static let servers = "kServers"
    static let selectedIndex = "kSelectedIndex"

    // Database
    static let databaseName = "kDatabaseName"

    // Authentication information
    static let token = "kAuthToken"
    static let serverURL = "kAuthServerURL"
    static let serverVersion = "kAuthServerVersion"
    static let userId = "kUserId"

    // Display information
    static let serverIconURL = "kServerIconURL"
    static let serverName = "kServerName"

    // Two-way SSL certificate & password
    static let sslClientCertificatePath = "kSSLClientCertificatePath"
    static let sslClientCertificatePassword = "kSSLClientCertificatePassword"
}

struct DatabaseManager {

    /**
        - returns: The selected database index.
     */
    static var selectedIndex: Int {
        return UserDefaults.group.value(forKey: ServerPersistKeys.selectedIndex) as? Int ?? 0
    }

    /**
        - returns: All servers stored locally into the app.
     */
    static var servers: [[String: String]]? {
        return UserDefaults.group.value(forKey: ServerPersistKeys.servers) as? [[String: String]]
    }

    /**
        - parameter index: The database index user wants to select.
     */
    static func selectDatabase(at index: Int) {
        UserDefaults.group.set(index, forKey: ServerPersistKeys.selectedIndex)
    }

    /**
        - parameter index: The database index that needs to be updated.
     */
    static func updateSSLClientInformation(for index: Int, path: URL, password: String) {
        guard
            var servers = self.servers,
            servers.count > index
        else {
            return
        }

        // Update SSL Client Certificate information
        var server = servers[index]
        server[ServerPersistKeys.sslClientCertificatePath] = path.absoluteString
        server[ServerPersistKeys.sslClientCertificatePassword] = password
        servers[index] = server

        UserDefaults.group.set(servers, forKey: ServerPersistKeys.servers)
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
        Removes server information at some index.
     
        parameter index: The database index user wants to delete.
     */
    static func removeDatabase(at index: Int) {
        if var servers = self.servers, servers.count > index {
            servers.remove(at: index)
            UserDefaults.group.set(servers, forKey: ServerPersistKeys.servers)
        }
    }

    /**
        This method cleans the servers that doesn't have
        authentication information.
     */
    static func cleanInvalidDatabases() {
        let servers = self.servers ?? []
        var validServers: [[String: String]] = []

        for (index, server) in servers.enumerated() {
            guard
                server[ServerPersistKeys.token] != nil,
                server[ServerPersistKeys.userId] != nil,
                server[ServerPersistKeys.databaseName] != nil,
                server[ServerPersistKeys.serverURL] != nil,
                let realmConfiguration = databaseConfiguration(index: index),
                (try? Realm(configuration: realmConfiguration)) != nil
            else {
                continue
            }

            validServers.append(server)
        }

        if selectedIndex > validServers.count - 1 {
            selectDatabase(at: 0)
        }

        UserDefaults.group.set(validServers, forKey: ServerPersistKeys.servers)
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
        let defaults = UserDefaults.group
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
     This method gets the realm associated with this server
    */
    static func databaseInstace(index: Int) -> Realm? {
        guard let configuration = databaseConfiguration(index: index) else { return nil }
        return try? Realm(configuration: configuration)
    }

    /**
     This method returns the realm configuration associated with this server
    */
    static func databaseConfiguration(index: Int? = nil) -> Realm.Configuration? {
        guard
            let server = AuthManager.selectedServerInformation(index: index),
            let databaseName = server[ServerPersistKeys.databaseName],
            let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)
        else {
            return nil
        }

        #if DEBUG
        Log.debug("Realm path: \(url.appendingPathComponent(databaseName))")
        #endif

        return Realm.Configuration(
            fileURL: url.appendingPathComponent(databaseName),
            deleteRealmIfMigrationNeeded: true
        )
    }
}

extension DatabaseManager {
    /**
     This method returns an index for the server with this URL if it already exists.
     - parameter serverUrl: The URL of the server
     */
    static func serverIndexForUrl(_ serverUrl: URL) -> Int? {
        return servers?.index {
            guard let url = URL(string: $0[ServerPersistKeys.serverURL] ?? "") else {
                return false
            }

            return url.host == serverUrl.host
        }
    }
}
