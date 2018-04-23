//
//  MigrationCoordinator.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct MigrationCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        migrateUserDefaultsStandardToGroupIfNeeded()
    }

    func migrateUserDefaultsStandardToGroupIfNeeded() {
        let isMigratedKey = "isUserDefaultsStandardMigratedToGroup"

        guard !UserDefaults.group.bool(forKey: isMigratedKey) else {
            return
        }

        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.group.set(
                UserDefaults.standard.dictionaryRepresentation()[$0],
                forKey: $0
            )
        }

        UserDefaults.group.set(true, forKey: isMigratedKey)
        UserDefaults.group.synchronize()
    }
}
