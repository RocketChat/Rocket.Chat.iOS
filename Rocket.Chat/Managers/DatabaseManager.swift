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

    static var selectedIndex: Int? {
        return UserDefaults.standard.value(forKey: ServerPersistKeys.selectedIndex) as? Int
    }

    static var servers: [[String: String]]? {
        return UserDefaults.standard.value(forKey: ServerPersistKeys.servers) as? [[String: String]]
    }

    static func selectDatabase(at index: Int) {
        UserDefaults.standard.set(index, forKey: ServerPersistKeys.selectedIndex)
    }

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

    static func changeDatabaseInstance(index: Int? = nil) {
        guard
            let server = AuthManager.selectedServerInformation(),
            let databaseName = server[ServerPersistKeys.databaseName]
        else {
            return
        }

        let configuration = Realm.Configuration(
            fileURL: URL(fileURLWithPath: RLMRealmPathForFile(databaseName), isDirectory: false),
            deleteRealmIfMigrationNeeded: true
        )

        realmInstance = try? Realm(configuration: configuration)
        dump(configuration.fileURL)
    }

}
