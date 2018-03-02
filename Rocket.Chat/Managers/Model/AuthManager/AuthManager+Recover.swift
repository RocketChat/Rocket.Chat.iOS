//
//  AuthManager+Recover.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension AuthManager {
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

        let defaults = UserDefaults.group

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
