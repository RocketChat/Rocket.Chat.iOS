//
//  RealmCurrent.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

var realmConfiguration: Realm.Configuration?
let realmTestingConfiguration = Realm.Configuration(
    inMemoryIdentifier: "realm-testing-identifier",
    deleteRealmIfMigrationNeeded: true
)

extension Realm {
    static var current: Realm? {
        var isTesting = false

        #if TEST
        isTesting = true
        #endif

        if isTesting {
            return try? Realm(configuration: realmTestingConfiguration)
        }

        if let configuration = realmConfiguration {
            return try? Realm(configuration: configuration)
        } else {
            let configuration = Realm.Configuration(
                deleteRealmIfMigrationNeeded: true
            )

            return try? Realm(configuration: configuration)
        }
    }
}
