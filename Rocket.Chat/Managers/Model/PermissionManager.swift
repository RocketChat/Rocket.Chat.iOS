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
    static func changes() {
        let eventName = "permissions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-logged",
            "params": [eventName, false]
            ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][1]

            Realm.execute({ (realm) in
                let permission = Permission.getOrCreate(realm: realm, values: object, updates: { _ in })
                realm.add(permission, update: true)
            })
        }
    }

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

    static func roles(for permission: PermissionType, realm: Realm? = Realm.shared) -> List<String>? {
        let object = realm?.object(ofType: Permission.self, forPrimaryKey: permission.rawValue)
        return object?.roles
    }
}

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
}
