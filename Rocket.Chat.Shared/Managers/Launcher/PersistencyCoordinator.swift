//
//  PersistencyCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct PersistencyCoordinator: LauncherCoordinator {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            deleteRealmIfMigrationNeeded: true
        )
    }
}
