//
//  UserManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserManager {

    static func changes() {
        let request = [
            "msg": "sub",
            "name": "activeUsers",
            "params": []
        ] as [String : Any]

        SocketManager.send(request) { _ in }
    }

    static func setUserPresence(status: UserStatus, completion: @escaping MessageCompletion) {
        let method = "UserPresence:".appending(status.rawValue)

        let request = [
            "msg": "method",
            "method": method,
            "params": []
        ] as [String : Any]

        SocketManager.send(request) { (response) in
            completion(response)
        }
    }

}
