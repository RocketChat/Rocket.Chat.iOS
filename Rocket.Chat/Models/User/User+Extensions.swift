//
//  User+Extensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension User {

    func hasPermission(_ permission: PermissionType, realm: Realm? = Realm.shared) -> Bool {
        guard let permissionRoles = PermissionManager.roles(for: permission, realm: realm) else { return false }

        for userRole in self.roles {
            for permissionRole in permissionRoles where userRole == permissionRole {
                return true
            }
        }

        return false
    }

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
            let auth = auth ?? AuthManager.isAuthenticated(),
            let baseURL = auth.baseURL(),
            let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        else {
            return nil
        }

        return URL(string: "\(baseURL)/avatar/\(encodedUsername)")
    }

    func canViewAdminPanel(realm: Realm? = Realm.shared) -> Bool {
        return hasPermission(.viewPrivilegedSetting, realm: realm) ||
            hasPermission(.viewStatistics, realm: realm) ||
            hasPermission(.viewUserAdministration, realm: realm) ||
            hasPermission(.viewRoomAdministration, realm: realm)
    }

}
