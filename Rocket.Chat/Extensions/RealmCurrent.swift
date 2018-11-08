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

    #if TEST
    static var current: Realm? {
        return try? Realm(configuration: realmTestingConfiguration)
    }
    #endif

    #if !TEST
    static var current: Realm? {
        if let configuration = realmConfiguration {
            return try? Realm(configuration: configuration)
        } else {
            let configuration = Realm.Configuration(
                deleteRealmIfMigrationNeeded: true
            )

            return try? Realm(configuration: configuration)
        }
    }
    #endif

}
