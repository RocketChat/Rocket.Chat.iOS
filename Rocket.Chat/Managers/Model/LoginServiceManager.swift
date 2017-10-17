//
//  LoginServiceManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct LoginServiceManager {
    static func changes() {
        let object = [
            "msg": "sub",
            "id": "6kSKFW4kkTyEDeG3E",
            "name": "meteor.loginServiceConfiguration",
            "params": []
            ] as [String: Any]

        SocketManager.subscribe(object, eventName: "meteor_accounts_loginServiceConfiguration") { _ in }
    }
}
