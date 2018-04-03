//
//  UserExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension User {
    static func search(usernameContaining word: String, preference: Set<String> = [], limit: Int = 5, realm: Realm? = Realm.current) -> [(String, Any)] {
        guard let realm = realm else { return [] }

        var result = [(String, Any)]()

        let users = (word.count > 0 ? realm.objects(User.self).filter("username CONTAINS[c] %@", word)
            : realm.objects(User.self)).sorted(by: { user, _ in
                guard let username = user.username else { return false }
                return preference.contains(username)
            })

        (0..<min(limit, users.count)).forEach {
            guard let username = users[$0].username else { return }
            result.append((username, users[$0]))
        }

        return result
    }
}
