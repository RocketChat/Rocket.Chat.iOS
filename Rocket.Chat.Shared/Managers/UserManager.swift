//
//  UserManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

/// A manager that manages all user related actions
public class UserManager: SocketManagerInjected {

    /// Dependency injection container, replace it to change the behavior of the user manager
    var injectionContainer: InjectionContainer!

    /// Subscribe active users' changes
    func changes() {
        let request = [
            "msg": "sub",
            "name": "activeUsers",
            "params": []
        ] as [String : Any]

        socketManager.send(request) { _ in }
    }

    /// Subscribe user data changes
    func userDataChanges() {
        let request = [
            "msg": "sub",
            "name": "userData",
            "params": []
        ] as [String : Any]

        socketManager.send(request) { _ in }
    }

    /// Set current user's statue
    ///
    /// - Parameters:
    ///   - status: new status
    ///   - completion: will be called after action completion
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

    /// Set current user's presence
    ///
    /// - Parameters:
    ///   - status: new presence
    ///   - completion: will be called after action completion
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
