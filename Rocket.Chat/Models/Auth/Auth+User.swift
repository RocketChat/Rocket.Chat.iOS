//
//  Auth+User.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Auth {
    var user: User? {
        guard let userId = userId else { return nil }

        let realm = self.realm ?? Realm.shared
        return realm?.object(ofType: User.self, forPrimaryKey: userId)
    }
}
