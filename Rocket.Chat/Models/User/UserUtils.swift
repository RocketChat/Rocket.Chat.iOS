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
        guard let validatedUser = validated() else {
            return ""
        }

        let username = validatedUser.username ?? ""

        guard let settings = AuthSettingsManager.settings else {
            return username
        }

        if let name = validatedUser.name {
            if settings.useUserRealName && !name.isEmpty {
                return name
            }
        }

        return username
    }

    func canViewAdminPanel(realm: Realm? = Realm.current) -> Bool {
        return hasPermission(.viewPrivilegedSetting, realm: realm) ||
            hasPermission(.viewStatistics, realm: realm) ||
            hasPermission(.viewUserAdministration, realm: realm) ||
            hasPermission(.viewRoomAdministration, realm: realm)
    }

}
