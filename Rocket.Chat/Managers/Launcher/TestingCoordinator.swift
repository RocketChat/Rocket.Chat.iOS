//
//  TestingCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 27/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Testing build is suppose to always start with a clean database.

 This should be always the first coordinator to be called in the stack
 of launchers, and also always only be executed when TEST runtime variable
 is present, otherwise we may compromise other builds.
 */
struct TestingCoordinator: LauncherProtocol {

    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        #if TEST
        Realm.clearDatabase()

        for idx in (DatabaseManager.servers ?? []).indices {
            DatabaseManager.removeDatabase(at: idx)
        }

        UserDefaults.group.removeObject(forKey: ServerPersistKeys.servers)
        #endif
    }

}
