//
//  RealmExtensions.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 18/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

@testable import Rocket_Chat

extension Realm {
    static func clearDatabase() {
        Realm.execute({ realm in
            realm.deleteAll()
        })
    }
}
