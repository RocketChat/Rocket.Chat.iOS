//
//  SubscriptionManager+Rooms.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SubscriptionManager {
    static func createDirectMessage(_ username: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "createDirectMessage",
            "params": [username]
            ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    static func getRoom(byName name: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "getRoomByTypeAndName",
            "params": ["c", name]
            ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    static func join(room rid: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "joinRoom",
            "params": [rid]
            ] as [String: Any]

        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
}
