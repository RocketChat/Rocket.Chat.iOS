//
//  UserUtils.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension User {
    func displayName() -> String {
        guard let settings = AuthSettingsManager.settings else {
            return username ?? ""
        }

        if let name = name {
            if settings.useUserRealName && !name.isEmpty {
                return name
            }
        }

        return username ?? ""
    }

    func avatarURL(_ auth: Auth? = nil) -> URL? {
        guard
            !isInvalidated,
            let username = username,
            let auth = auth ?? AuthManager.isAuthenticated()
        else {
            return nil
        }

        return User.avatarURL(forUsername: username, auth: auth)
    }

    func canViewAdminPanel(realm: Realm? = Realm.current) -> Bool {
        return hasPermission(.viewPrivilegedSetting, realm: realm) ||
            hasPermission(.viewStatistics, realm: realm) ||
            hasPermission(.viewUserAdministration, realm: realm) ||
            hasPermission(.viewRoomAdministration, realm: realm)
    }

    static func avatarURL(forUsername username: String, auth: Auth? = nil) -> URL? {
        guard
            let auth = auth ?? AuthManager.isAuthenticated(),
            let baseURL = auth.baseURL(),
            let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        else {
            return nil
        }

        return URL(string: "\(baseURL)/avatar/\(encodedUsername)?format=jpeg")
    }
}
