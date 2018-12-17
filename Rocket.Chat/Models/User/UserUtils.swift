//
//  UserUtils.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension User {

    func canViewAdminPanel(realm: Realm? = Realm.current) -> Bool {
        return hasPermission(.viewPrivilegedSetting, realm: realm) ||
            hasPermission(.viewStatistics, realm: realm) ||
            hasPermission(.viewUserAdministration, realm: realm) ||
            hasPermission(.viewRoomAdministration, realm: realm)
    }

}
