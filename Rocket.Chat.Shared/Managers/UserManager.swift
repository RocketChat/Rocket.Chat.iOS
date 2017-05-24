//
//  UserManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

public struct UserManager: SocketManagerInjected {

    var injectionContainer: InjectionContainer!

    func changes() {
        let request = [
            "msg": "sub",
            "name": "activeUsers",
            "params": []
        ] as [String : Any]

        socketManager.send(request) { _ in }
    }

    func userDataChanges() {
        let request = [
            "msg": "sub",
            "name": "userData",
            "params": []
        ] as [String : Any]

        socketManager.send(request) { _ in }
    }

    public func setUserStatus(status: UserStatus, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "UserPresence:setDefaultStatus",
            "params": [status.rawValue]
        ] as [String : Any]

        socketManager.send(request) { (response) in
            completion(response)
        }
    }

    public func setUserPresence(status: UserPresence, completion: @escaping MessageCompletion) {
        let method = "UserPresence:".appending(status.rawValue)

        let request = [
            "msg": "method",
            "method": method,
            "params": []
        ] as [String : Any]

        socketManager.send(request) { (response) in
            completion(response)
        }
    }

}
