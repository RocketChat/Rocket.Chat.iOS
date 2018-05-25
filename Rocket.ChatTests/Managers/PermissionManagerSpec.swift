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

class PermissionManagerSpec: XCTestCase, RealmTestCase {
    func testRolesForPermission() throws {
        let permissionType = PermissionType.createDirectMessages

        let permission = Rocket_Chat.Permission()
        permission.identifier = permissionType.rawValue
        permission.roles.append(contentsOf: ["admin", "user"])

        let realm = testRealm()
        try realm.write {
            realm.add(permission)
        }

        guard let roles = PermissionManager.roles(for: permissionType, realm: realm) else {
            XCTFail("roles is not nil")
            return
        }

        XCTAssertEqual(roles[0], "admin", "has admin role")
        XCTAssertEqual(roles[1], "user", "has user role")
    }

    func testUserHasPermission() throws {
        let permissionType = PermissionType.createDirectMessages

        let permission = Rocket_Chat.Permission()
        permission.identifier = permissionType.rawValue
        permission.roles.append(contentsOf: ["admin", "user"])

        let realm = testRealm()
        try realm.write {
            realm.add(permission)
        }

        let user = User()
        user.roles.append("user")

        XCTAssertTrue(user.hasPermission(permissionType, realm: realm), "user has permission")

        user.roles.removeAll()

        XCTAssertFalse(user.hasPermission(permissionType, realm: realm), "user has no permission")
    }
}
