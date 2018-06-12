//
//  LoginServiceManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct LoginServiceManager {
    let observeTokens: [NotificationToken]

    static func subscribe() {
        let object = [
            "msg": "sub",
            "name": "meteor.loginServiceConfiguration",
            "params": []
        ] as [String: Any]

        SocketManager.subscribe(object, eventName: "meteor_accounts_loginServiceConfiguration") { _ in }
    }
}

// MARK: Realm
extension LoginServiceManager {
    static func observe(block: @escaping (RealmCollectionChange<Results<LoginService>>) -> Void) -> NotificationToken? {
        let objects = Realm.current?.objects(LoginService.self)
        return objects?.observe(block)
    }
}
