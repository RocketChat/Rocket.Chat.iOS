//
//  UserExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension User {
    func updateStatus(status: UserStatus) {
        let userIdentifier = self.identifier

        Realm.execute({ (realm) in
            if let identifier = userIdentifier, let user = User.find(withIdentifier: identifier) {
                user.status = status
                realm.add(user, update: true)
            }
        })
    }

    static func search(
        usernameContaining word: String,
        preference: [String] = [],
        limit: Int = 5,
        includeSelf: Bool = true,
        realm: Realm? = Realm.current
    ) -> [(String, Any)] {
        guard let realm = realm else { return [] }

        var result = [(String, Any)]()

        let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", word)
        let usernamePredicate = NSPredicate(format: "username CONTAINS[c] %@", word)
        let nameOrUsernamePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, usernamePredicate])
        var users = (word.count > 0 ? realm.objects(User.self).filter(nameOrUsernamePredicate)
            : realm.objects(User.self)).sorted(by: { user, _ -> Bool in
                guard let username = user.username else { return false }
                return preference.contains(username)
            })

        if !includeSelf {
            users = users.filter {
                $0 != AuthManager.currentUser(realm: realm)
            }
        }

        let shouldUseRealName = AuthSettingsManager.settings?.useUserRealName ?? false
        (0..<min(limit, users.count)).forEach {
            let titleField = shouldUseRealName ? users[$0].name : users[$0].username
            guard let title = titleField else { return }
            result.append((title, users[$0]))
        }

        return result
    }
}
