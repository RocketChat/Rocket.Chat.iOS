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

    static func createNewDatabaseInstance(serverURL: String) -> Int {
        let defaults = UserDefaults.standard
        var servers = defaults.value(forKey: AuthManagerPersistKeys.servers) as? [[String: String]] ?? []

        servers.append([
            AuthManagerPersistKeys.databaseName: "\(String.random()).realm",
            AuthManagerPersistKeys.serverURL: serverURL
        ])

        let index = servers.count - 1
        defaults.set(servers, forKey: AuthManagerPersistKeys.servers)
        defaults.set(index, forKey: AuthManagerPersistKeys.selectedIndex)
        return index
    }

    static func changeDatabaseInstance(index: Int? = nil) {
        guard
            let server = AuthManager.selectedServerInformation(),
            let databaseName = server[AuthManagerPersistKeys.databaseName]
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
