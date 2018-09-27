//
//  PersistencyCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct PersistencyCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        #if TEST
        for (idx, _) in (DatabaseManager.servers ?? []).enumerated() {
            DatabaseManager.removeDatabase(at: idx)
        }
        #endif

        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()
        AuthManager.recoverAuthIfNeeded()
    }
}
