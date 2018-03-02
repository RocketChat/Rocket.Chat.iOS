//
//  AuthManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

struct AuthManager {

    /**
        - returns: Last auth object (sorted by lastAccess), if exists.
    */
    static func isAuthenticated(realm: Realm? = Realm.shared) -> Auth? {
        guard let realm = realm else { return nil }
        return realm.objects(Auth.self).sorted(byKeyPath: "lastAccess", ascending: false).first
    }

    /**
        This method is going to persist the authentication informations
        that was latest used in NSUserDefaults to keep it safe if something
        goes wrong on database migration.
     */
    static func persistAuthInformation(_ auth: Auth) {
        let defaults = UserDefaults.group
        let selectedIndex = DatabaseManager.selectedIndex

        guard
            let token = auth.token,
            let userId = auth.userId,
            var servers = DatabaseManager.servers,
            servers.count > selectedIndex
        else {
            return
        }

        servers[selectedIndex][ServerPersistKeys.token] = token
        servers[selectedIndex][ServerPersistKeys.userId] = userId

        defaults.set(servers, forKey: ServerPersistKeys.servers)
    }

    static func selectedServerInformation(index: Int? = nil) -> [String: String]? {
        guard
            let servers = DatabaseManager.servers,
            servers.count > 0
        else {
            return nil
        }

        var server: [String: String]?
        if let index = index {
            server = servers[index]
        } else {
            if DatabaseManager.selectedIndex >= servers.count {
                DatabaseManager.selectDatabase(at: 0)
            }

            server = servers[DatabaseManager.selectedIndex]
        }

        return server
    }
}
