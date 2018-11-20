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
        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()
        AuthManager.recoverAuthIfNeeded()
    }
}
