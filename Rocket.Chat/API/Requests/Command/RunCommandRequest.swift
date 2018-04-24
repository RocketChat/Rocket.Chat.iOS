//
//  RunCommandRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: ??

import SwiftyJSON

typealias RunCommandSucceeded = (RunCommandResource) -> Void

final class RunCommandRequest: APIRequest {
    typealias APIResourceType = RunCommandResource

    let method: HTTPMethod = .post
    let path = "/api/v1/commands.run"
    let requiredVersion = Version(0, 60, 0)

    let command: String
    let params: String
    let roomId: String

    init(command: String, params: String, roomId: String) {
        self.command = command
        self.params = params
        self.roomId = roomId
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": roomId,
            "command": command,
            "params": params
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class RunCommandResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
