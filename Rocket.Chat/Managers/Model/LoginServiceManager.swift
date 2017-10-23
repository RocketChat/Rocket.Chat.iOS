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
            "id": "6kSKFW4kkTyEDeG3E",
            "name": "meteor.loginServiceConfiguration",
            "params": []
            ] as [String: Any]

        SocketManager.subscribe(object, eventName: "meteor_accounts_loginServiceConfiguration") { _ in }
    }
}

// MARK: Realm
extension LoginServiceManager {
    static func observe(block: @escaping (RealmCollectionChange<Results<LoginService>>) -> Void) -> NotificationToken? {
        let objects = Realm.shared?.objects(LoginService.self)
        return objects?.observe(block)
    }
}
