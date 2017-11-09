//
//  PermissionManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Rocket_Chat

class PermissionManagerSpec: XCTest {
    func testRolesForPermission() {
        let permissionType = PermissionType.createDirectMessages

        let permission = Permission()
        permission.identifier = permissionType.rawValue
        permission.roles.append(contentsOf: ["admin", "user"])
        Realm.shared?.add(permission)

        guard let roles = PermissionManager.roles(for: permissionType) else {
            XCTFail("roles is not nil")
            return
        }

        XCTAssertEqual(roles[0], "admin", "has admin role")
        XCTAssertEqual(roles[1], "user", "has user role")
    }

    func testUserHasPermission() {
        let permissionType = PermissionType.createDirectMessages

        let permission = Permission()
        permission.identifier = permissionType.rawValue
        permission.roles.append(contentsOf: ["admin", "user"])
        Realm.shared?.add(permission)

        let user = User()
        user.roles.append("user")

        XCTAssertTrue(user.hasPermission(permissionType), "user has permission")

        user.roles.removeAll()

        XCTAssertFalse(user.hasPermission(permissionType), "user has no permission")
    }
}
