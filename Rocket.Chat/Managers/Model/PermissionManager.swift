//
//  PermissionManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct PermissionManager {
    static func updatePermissions() {
        let requestPermissions = [
            "msg": "method",
            "method": "permissions/get",
            "params": []
        ] as [String: Any]

        SocketManager.send(requestPermissions) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let permissions = List<Permission>()

            // List is used the first time user opens the app
            let list = response.result["result"].array

            // Update & Removed is used on updates
            let updated = response.result["result"]["update"].array
            let removed = response.result["result"]["remove"].array

            Realm.execute({ realm in
                list?.forEach { object in
                    let permission = Permission.getOrCreate(realm: realm, values: object, updates: nil)
                    permissions.append(permission)
                }

                updated?.forEach { object in
                    let permission = Permission.getOrCreate(realm: realm, values: object, updates: nil)
                    permissions.append(permission)
                }

                removed?.forEach { object in
                    let permission = Permission.getOrCreate(realm: realm, values: object, updates: nil)
                    permissions.append(permission)
                }

                realm.add(permissions, update: true)
            })
        }
    }

    static func roles(for permission: PermissionType) -> [Role]? {
        let object = Realm.shared?.object(ofType: Permission.self, forPrimaryKey: permission.rawValue)
        return object?.roles
    }
}
