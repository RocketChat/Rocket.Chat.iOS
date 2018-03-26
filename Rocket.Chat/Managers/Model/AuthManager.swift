//
//  AuthManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

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
        - returns: Current user object, if exists.
    */
    static func currentUser() -> User? {
        return isAuthenticated()?.user
    }

    /**
        This method is going to persist the authentication informations
        that was latest used in NSUserDefaults to keep it safe if something
        goes wrong on database migration.
     */
    static func persistAuthInformation(_ auth: Auth) {
        let defaults = UserDefaults.standard
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

    /**
        This method migrates the old authentication storaged format
        to a new one that supports multiple authentication at the
        same app installation.
     
        Last version using the old format: 1.2.1.
     */
    static func recoverOldAuthFormatIfNeeded() {
        if AuthManager.isAuthenticated() != nil {
            return
        }

        let defaults = UserDefaults.standard

        guard
            let token = defaults.string(forKey: ServerPersistKeys.token),
            let serverURL = defaults.string(forKey: ServerPersistKeys.serverURL),
            let userId = defaults.string(forKey: ServerPersistKeys.userId) else {
                return
        }

        let servers = [[
            ServerPersistKeys.databaseName: "\(String.random()).realm",
            ServerPersistKeys.token: token,
            ServerPersistKeys.serverURL: serverURL,
            ServerPersistKeys.userId: userId
        ]]

        defaults.set(0, forKey: ServerPersistKeys.selectedIndex)
        defaults.set(servers, forKey: ServerPersistKeys.servers)
        defaults.removeObject(forKey: ServerPersistKeys.token)
        defaults.removeObject(forKey: ServerPersistKeys.serverURL)
        defaults.removeObject(forKey: ServerPersistKeys.userId)
    }

    /**
        Recovers the authentication on database if needed
     */
    static func recoverAuthIfNeeded() {
        if AuthManager.isAuthenticated() != nil {
            return
        }

        recoverOldAuthFormatIfNeeded()

        guard
            let server = selectedServerInformation(),
            let token = server[ServerPersistKeys.token],
            let serverURL = server[ServerPersistKeys.serverURL],
            let userId = server[ServerPersistKeys.userId]
        else {
            return
        }

        DatabaseManager.changeDatabaseInstance()

        Realm.executeOnMainThread({ (realm) in
            // Clear database
            realm.deleteAll()

            let auth = Auth()
            auth.lastSubscriptionFetch = nil
            auth.lastAccess = Date()
            auth.serverURL = serverURL
            auth.token = token
            auth.userId = userId
            auth.serverVersion = server[ServerPersistKeys.serverVersion] ?? ""

            PushManager.updatePushToken()

            realm.add(auth)
        })
    }
}
